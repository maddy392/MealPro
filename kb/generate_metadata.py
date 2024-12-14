import csv
import json

def generate_json_metadata(csv_file, content_field, metadata_fields, excluded_fields):
    # Open the CSV file and read its contents
    with open(csv_file, 'r') as file:
        reader = csv.DictReader(file)
        headers = reader.fieldnames

    # Create the JSON structure
    json_data = {
        "metadataAttributes": {},
        "documentStructureConfiguration": {
            "type": "RECORD_BASED_STRUCTURE_METADATA",
            "recordBasedStructureMetadata": {
                "contentFields": [
                    {
                        "fieldName": content_field
                    }
                ],
                "metadataFieldsSpecification": {
                    "fieldsToInclude": [],
                    "fieldsToExclude": []
                }
            }
        }
    }

    # Add metadata fields to include
    for field in metadata_fields:
        json_data["documentStructureConfiguration"]["recordBasedStructureMetadata"]["metadataFieldsSpecification"]["fieldsToInclude"].append(
            {
                "fieldName": field
            }
        )

    # Add fields to exclude (all fields not in content_field or metadata_fields)
    if not excluded_fields:
        excluded_fields = set(headers) - set([content_field] + metadata_fields)
    
    for field in excluded_fields:
        json_data["documentStructureConfiguration"]["recordBasedStructureMetadata"]["metadataFieldsSpecification"]["fieldsToExclude"].append(
            {
                "fieldName": field
            }
        )

    # Generate the output JSON file name
    output_file = f"{csv_file.split('.')[0]}.csv.metadata.json"

    # Write the JSON data to the output file
    with open(output_file, 'w') as file:
        json.dump(json_data, file, indent=4)

    print(f"JSON metadata file '{output_file}' has been generated.")

csv_file = 'all_recipes.csv'
content_field = 'title'
metadata_fields = ['id', 'title', 'vegetarian', 'vegan', 'glutenFree', 'dairyFree']
excluded_fields = ['analyzedInstructions']

generate_json_metadata(csv_file, content_field, metadata_fields, excluded_fields)

