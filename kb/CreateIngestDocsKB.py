import json
import os
import boto3
from botocore.exceptions import ClientError
import random
from utility import attach_policies_to_existing_role, create_policies_in_oss, create_oss_policy_attach_bedrock_execution_role, interactive_sleep
import time


boto3_session = boto3.Session(profile_name="mealPro", region_name="us-east-1")

sts_client = boto3_session.client('sts')
iam_client = boto3_session.client('iam')
region_name = boto3_session.region_name

bedrock_agent_client = boto3_session.client('bedrock-agent', region_name=region_name)
bedrock_agent_runtime_client = boto3_session.client('bedrock-agent-runtime', region_name=region_name)

service = "aoss"
s3_client = boto3_session.client('s3', region_name=region_name)
account_id = sts_client.get_caller_identity()["Account"]
s3_suffix = f"{region_name}-{account_id}"
# suffix = random.randrange(200, 900)
suffix = 637


print(boto3.__version__)

bucket_name = f"bedrock-kb-{s3_suffix}-1"

data_sources = [
	{"type": "S3", "bucket_name": bucket_name}
]

# check if bucket exists; if not create a bucket
for ds in [d for d in data_sources if d["type"] == "S3"]:
	bucket_name = ds["bucket_name"]
	try:
		s3_client.head_bucket(Bucket=bucket_name)
		print(f"Bucket {bucket_name} exists.")
	except ClientError as e:
		print(f"Bucket {bucket_name} does not exist. Creating bucket...")
		if region_name == "us-east-1":
			s3_client.create_bucket(Bucket=bucket_name)
		else:
			s3_client.create_bucket(Bucket=bucket_name, 
			CreateBucketConfiguration={'LocationConstraint': region_name}
			)

# Create a vector Store in AOSS
vector_store_name = f"bedrock-sample-rag-{suffix}"
index_name = f"bedrock-sample-rag-index-{suffix}"
aoss_client = boto3_session.client('opensearchserverless', region_name=region_name)
bedrock_execution_role_name = 'AmazonBedrockExecutionRoleForAgents_5SVAH2QGYCW'
bedrock_execution_role = iam_client.get_role(RoleName=bedrock_execution_role_name)
# attach_policies_to_existing_role(bedrock_execution_role_name, bucket_name)
bedrock_kb_execution_role_arn = bedrock_execution_role['Role']['Arn']

# create security, network and data access policies within OSS
# encryption_policy, network_policy, access_policy = create_policies_in_oss(vector_store_name=vector_store_name,
#                        aoss_client=aoss_client,
#                        bedrock_kb_execution_role_arn=bedrock_kb_execution_role_arn)
# collection = aoss_client.create_collection(name=vector_store_name, type='VECTORSEARCH')


# Get the OpenSearch serverless collection URL
collection_id = '32aurwiaiy9901ylyz1a'
# collection['createCollectionDetail']['id']
host = collection_id + '.' + region_name + '.aoss.amazonaws.com'
print(host)


response = aoss_client.batch_get_collection(
    names=[vector_store_name]
)

iam_client.attach_role_policy(
	RoleName=bedrock_execution_role["Role"]["RoleName"],
	PolicyArn='arn:aws:iam::294090989896:policy/AmazonBedrockOSSPolicyForKnowledgeBase_340'
)


from opensearchpy import OpenSearch, RequestsHttpConnection, AWSV4SignerAuth, RequestError
credentials = boto3_session.get_credentials()
awsauth = auth = AWSV4SignerAuth(credentials, region_name, service)

index_name = f"bedrock-sample-index-{suffix}"
body_json = {
   "settings": {
      "index.knn": "true",
       "number_of_shards": 1,
       "knn.algo_param.ef_search": 512,
       "number_of_replicas": 0,
   },
   "mappings": {
      "properties": {
         "vector": {
            "type": "knn_vector",
            "dimension": 1024,
             "method": {
                 "name": "hnsw",
                 "engine": "faiss",
                 "space_type": "l2"
             },
         },
         "text": {
            "type": "text"
         },
         "text-metadata": {
            "type": "text"         }
      }
   }
}

oss_client = OpenSearch(
	hosts=[{"host": host, "port": 443}],
	http_auth=awsauth, 
	use_ssl=True, 
	verify_certs=True, 
	connection_class=RequestsHttpConnection,
	timeout=300
)

try:
	response = oss_client.indices.create(index=index_name, body=json.dumps(body_json))
	print('\nCreating index:')
	interactive_sleep(60)
except RequestError as e:
	print(f'Error while trying to create the index, with error {e.error}\nyou may unmark the delete above to delete, and recreate the index')

# upload data to s3


# create knowledge base
opensearchServerlessConfiguration = {
	"collectionArn": "arn:aws:aoss:us-east-1:294090989896:collection/32aurwiaiy9901ylyz1a", 
	"vectorIndexName": index_name, 
	"fieldMapping": {
		"vectorField": "vector", 
		"textField": "text", 
		"metadataField": "text-metadata"
	}
}

embeddingModelArn = f"arn:aws:bedrock:{region_name}::foundation-model/amazon.titan-embed-text-v2:0"

name = f"bedrock-sample-knowledge-base-{suffix}"
description = "amazon shareholder letter knowledge base"
roleArn = bedrock_execution_role["Role"]["Arn"]

from retrying import retry

@retry(wait_random_min=1000, wait_random_max=2000, stop_max_attempt_number=7)
def create_knowledge_base_func():
	create_kb_response = bedrock_agent_client.create_knowledge_base(
		name=name, 
		description=description, 
		roleArn=roleArn, 
		knowledgeBaseConfiguration={
			"type": "VECTOR", 
			"vectorKnowledgeBaseConfiguration": {
				"embeddingModelArn": embeddingModelArn
			}
		}, 
		storageConfiguration = {
			"type": "OPENSEARCH_SERVERLESS", 
			"opensearchServerlessConfiguration": opensearchServerlessConfiguration
		}
	)

	return create_kb_response

try:
    kb = create_knowledge_base_func()
except Exception as err:
    print(f"{err=}, {type(err)=}")

get_kb_response = bedrock_agent_client.get_knowledge_base(knowledgeBaseId = kb['knowledgeBase']['knowledgeBaseId'])

# Function to create KB
def create_ds(data_sources):
    ds_list=[]
    for idx, ds in enumerate(data_sources):
        # Ingest strategy - How to ingest data from the data source
        chunkingStrategyConfiguration = {
            "chunkingStrategy": "FIXED_SIZE", 
            "fixedSizeChunkingConfiguration": {
                "maxTokens": 512,
                "overlapPercentage": 20
            }
        }
        
        # The data source to ingest documents from, into the OpenSearch serverless knowledge base index
        
        s3DataSourceConfiguration = {
                "type": "S3",
                "s3Configuration":{
                    "bucketArn": "",
                    # "inclusionPrefixes":["*.*"] # you can use this if you want to create a KB using data within s3 prefixes.
                    }
            }
        
        confluenceDataSourceConfiguration = {
            "confluenceConfiguration": {
                "sourceConfiguration": {
                    "hostUrl": "",
                    "hostType": "SAAS",
                    "authType": "", # BASIC | OAUTH2_CLIENT_CREDENTIALS
                    "credentialsSecretArn": ""
                    
                },
                "crawlerConfiguration": {
                    "filterConfiguration": {
                        "type": "PATTERN",
                        "patternObjectFilter": {
                            "filters": [
                                {
                                    "objectType": "Attachment",
                                    "inclusionFilters": [
                                        ".*\\.pdf"
                                    ],
                                    "exclusionFilters": [
                                        ".*private.*\\.pdf"
                                    ]
                                }
                            ]
                        }
                    }
                }
            },
            "type": "CONFLUENCE"
        }

        sharepointDataSourceConfiguration = {
            "sharePointConfiguration": {
                "sourceConfiguration": {
                    "tenantId": "",
                    "hostType": "ONLINE",
                    "domain": "domain",
                    "siteUrls": [],
                    "authType": "", # BASIC | OAUTH2_CLIENT_CREDENTIALS
                    "credentialsSecretArn": ""
                    
                },
                "crawlerConfiguration": {
                    "filterConfiguration": {
                        "type": "PATTERN",
                        "patternObjectFilter": {
                            "filters": [
                                {
                                    "objectType": "Attachment",
                                    "inclusionFilters": [
                                        ".*\\.pdf"
                                    ],
                                    "exclusionFilters": [
                                        ".*private.*\\.pdf"
                                    ]
                                }
                            ]
                        }
                    }
                }
            },
            "type": "SHAREPOINT"
        }


        salesforceDataSourceConfiguration = {
            "salesforceConfiguration": {
                "sourceConfiguration": {
                    "hostUrl": "",
                    "authType": "", # BASIC | OAUTH2_CLIENT_CREDENTIALS
                    "credentialsSecretArn": ""
                },
                "crawlerConfiguration": {
                    "filterConfiguration": {
                        "type": "PATTERN",
                        "patternObjectFilter": {
                            "filters": [
                                {
                                    "objectType": "Attachment",
                                    "inclusionFilters": [
                                        ".*\\.pdf"
                                    ],
                                    "exclusionFilters": [
                                        ".*private.*\\.pdf"
                                    ]
                                }
                            ]
                        }
                    }
                }
            },
            "type": "SALESFORCE"
        }

        webcrawlerDataSourceConfiguration = {
            "webConfiguration": {
                "sourceConfiguration": {
                    "urlConfiguration": {
                        "seedUrls": []
                    }
                },
                "crawlerConfiguration": {
                    "crawlerLimits": {
                        "rateLimit": 50
                    },
                    "scope": "HOST_ONLY",
                    "inclusionFilters": [],
                    "exclusionFilters": []
                }
            },
            "type": "WEB"
        }

        # Set the data source configuration based on the Data source type

        if ds['type'] == "S3":
            print(f'{idx +1 } data source: S3')
            ds_name = f'{name}-{bucket_name}'
            s3DataSourceConfiguration["s3Configuration"]["bucketArn"] = f'arn:aws:s3:::{ds["bucket_name"]}'
            # print(s3DataSourceConfiguration)
            data_source_configuration = s3DataSourceConfiguration
        
        if ds['type'] == "CONFLUENCE":
            print(f'{idx +1 } data source: CONFLUENCE')
            ds_name = f'{name}-confluence'
            confluenceDataSourceConfiguration['confluenceConfiguration']['sourceConfiguration']['hostUrl'] = ds['hostUrl']
            confluenceDataSourceConfiguration['confluenceConfiguration']['sourceConfiguration']['authType'] = ds['authType']
            confluenceDataSourceConfiguration['confluenceConfiguration']['sourceConfiguration']['credentialsSecretArn'] = ds['credentialsSecretArn']
            # print(confluenceDataSourceConfiguration)
            data_source_configuration = confluenceDataSourceConfiguration

        if ds['type'] == "SHAREPOINT":
            print(f'{idx +1 } data source: SHAREPOINT')
            ds_name = f'{name}-sharepoint'
            sharepointDataSourceConfiguration['sharePointConfiguration']['sourceConfiguration']['tenantId'] = ds['tenantId']
            sharepointDataSourceConfiguration['sharePointConfiguration']['sourceConfiguration']['domain'] = ds['domain']
            sharepointDataSourceConfiguration['sharePointConfiguration']['sourceConfiguration']['authType'] = ds['authType']
            sharepointDataSourceConfiguration['sharePointConfiguration']['sourceConfiguration']['siteUrls'] = ds["siteUrls"]
            sharepointDataSourceConfiguration['sharePointConfiguration']['sourceConfiguration']['credentialsSecretArn'] = ds['credentialsSecretArn']
            # print(sharepointDataSourceConfiguration)
            data_source_configuration = sharepointDataSourceConfiguration


        if ds['type'] == "SALESFORCE":
            print(f'{idx +1 } data source: SALESFORCE')
            ds_name = f'{name}-salesforce'
            salesforceDataSourceConfiguration['salesforceConfiguration']['sourceConfiguration']['hostUrl'] = ds['hostUrl']
            salesforceDataSourceConfiguration['salesforceConfiguration']['sourceConfiguration']['authType'] = ds['authType']
            salesforceDataSourceConfiguration['salesforceConfiguration']['sourceConfiguration']['credentialsSecretArn'] = ds['credentialsSecretArn']
            # print(salesforceDataSourceConfiguration)
            data_source_configuration = salesforceDataSourceConfiguration

        if ds['type'] == "WEB":
            print(f'{idx +1 } data source: WEB')
            ds_name = f'{name}-web'
            webcrawlerDataSourceConfiguration['webConfiguration']['sourceConfiguration']['urlConfiguration']['seedUrls'] = ds['seedUrls']
            webcrawlerDataSourceConfiguration['webConfiguration']['crawlerConfiguration']['inclusionFilters'] = ds['inclusionFilters']
            webcrawlerDataSourceConfiguration['webConfiguration']['crawlerConfiguration']['exclusionFilters'] = ds['exclusionFilters']
            # print(webcrawlerDataSourceConfiguration)
            data_source_configuration = webcrawlerDataSourceConfiguration
            

        # Create a DataSource in KnowledgeBase 
        create_ds_response = bedrock_agent_client.create_data_source(
            name = ds_name,
            description = description,
            knowledgeBaseId = kb['knowledgeBase']['knowledgeBaseId'],
            dataSourceConfiguration = data_source_configuration,
            vectorIngestionConfiguration = {
                "chunkingConfiguration": chunkingStrategyConfiguration
            }
        )
        ds = create_ds_response["dataSource"]
        pprint(ds)
        ds_list.append(ds)
    return ds_list

data_sources_list = create_ds(data_sources)

# Get DataSource 
for idx, ds in enumerate(data_sources_list):
    pprint(bedrock_agent_client.get_data_source(knowledgeBaseId = kb['knowledgeBase']['knowledgeBaseId'], dataSourceId = ds["dataSourceId"]))
    print(" ")

interactive_sleep(30)
ingest_jobs=[]
# Start an ingestion job
for idx, ds in enumerate(data_sources_list):
    try:
        start_job_response = bedrock_agent_client.start_ingestion_job(knowledgeBaseId = kb['knowledgeBase']['knowledgeBaseId'], dataSourceId = ds["dataSourceId"])
        job = start_job_response["ingestionJob"]
        print(f"job {idx} started successfully\n")
    
        while job['status'] not in ["COMPLETE", "FAILED", "STOPPED"]:
            get_job_response = bedrock_agent_client.get_ingestion_job(
              knowledgeBaseId = kb['knowledgeBase']['knowledgeBaseId'],
                dataSourceId = ds["dataSourceId"],
                ingestionJobId = job["ingestionJobId"]
          )
            job = get_job_response["ingestionJob"]
        pprint(job)
        interactive_sleep(40)

        ingest_jobs.append(job)
    except Exception as e:
        print(f"Couldn't start {idx} job.\n")
        print(e)

# Print the knowledge base Id in bedrock, that corresponds to the Opensearch index in the collection we created before, we will use it for the invocation later
kb_id = kb['knowledgeBase']['knowledgeBaseId']
pprint(kb_id)

query = "Provide a summary of consolidated statements of cash flows of Octank Financial for the fiscal years ended December 31, 2019?"

foundation_model = "anthropic.claude-3-sonnet-20240229-v1:0"

response = bedrock_agent_runtime_client.retrieve_and_generate(
    input={
        "text": query
    },
    retrieveAndGenerateConfiguration={
        "type": "KNOWLEDGE_BASE",
        "knowledgeBaseConfiguration": {
            'knowledgeBaseId': kb_id,
            "modelArn": "arn:aws:bedrock:{}::foundation-model/{}".format(region_name, foundation_model),
            "retrievalConfiguration": {
                "vectorSearchConfiguration": {
                    "numberOfResults":5
                } 
            }
        }
    }
)

print(response['output']['text'],end='\n'*2)


response_ret = bedrock_agent_runtime_client.retrieve(
    knowledgeBaseId=kb_id, 
    nextToken='string',
    retrievalConfiguration={
        "vectorSearchConfiguration": {
            "numberOfResults":5,
        } 
    },
    retrievalQuery={
        "text": "How many new positions were opened across Amazon's fulfillment and delivery network?"
    }
)

def response_print(retrieve_resp):
#structure 'retrievalResults': list of contents. Each list has content, location, score, metadata
    for num,chunk in enumerate(response_ret['retrievalResults'],1):
        print(f'Chunk {num}: ',chunk['content']['text'],end='\n'*2)
        print(f'Chunk {num} Location: ',chunk['location'],end='\n'*2)
        print(f'Chunk {num} Score: ',chunk['score'],end='\n'*2)
        print(f'Chunk {num} Metadata: ',chunk['metadata'],end='\n'*2)

response_print(response_ret)