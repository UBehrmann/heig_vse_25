import xml.etree.ElementTree as ET
from os import mkdir
from sotalya.processing.tucuxirun import TucuCliRun, TucuPycliRun, TucuServerRun
import random
import string


def modify_integers_to_negative(input_file, output_file):
    # Parse the XML file
    tree = ET.parse(input_file)
    root = tree.getroot()

    # Recursive function to process each element
    def process_element(element):
        for child in element:
            # Check if the field is an integer
            try:
                value = int(child.text)
                # Make the value negative if it is positive
                child.text = str(-abs(value))
            except (ValueError, TypeError):
                # If not an integer or empty, skip
                pass
            # Recurse into child elements
            process_element(child)

    # Process the root element
    process_element(root)

    # Write the modified tree back to a file
    tree.write(output_file, encoding="utf-8", xml_declaration=True)
    print(f"Modified XML saved to {output_file}")

# Example usage
input_file = "imatinib.tqf"  # Replace with your input XML file
output_file = "output.xml"  # Replace with your desired output file
modify_integers_to_negative(input_file, output_file)


tucuxi_run = TucuPycliRun('drugfiles')
query_response = tucuxi_run.run_tucuxi_from_file('imatinib.tqf')

index = 0

def modify_integers_to_negative_and_test(input_file:str, type_of_test:int):
    # Parse the XML file
    tree = ET.parse(input_file)
    root = tree.getroot()

    # Recursive function to process each element
    def process_element(element):
        global index
        for child in element:
            if type_of_test == 1:
                # Check if the field is an integer
                try:
                    value = int(child.text)
                    # Make the value negative if it is positive
                    child.text = str(-abs(value))
                    # Write the modified tree back to a file
                    index = index + 1
                    output_file = 'tmptqf/' + input_file + str(index)
                    tree.write(output_file, encoding="utf-8", xml_declaration=True)
                    print(f"Modified XML saved to {output_file}")
                    query_response = tucuxi_run.run_tucuxi_from_file(output_file)
                    print(f"Query status: {query_response.queryStatus.statusCode}")
                    print(f"Query statusLit: {query_response.queryStatus.statusCodeLit}")
                    print(f"Query description: {query_response.queryStatus.description}")
                    print(f"Query message: {query_response.queryStatus.message}")

                    # Back to normal
                    child.text = str(value)

                except (ValueError, TypeError):
                    # If not an integer or empty, skip
                    pass
                
            elif type_of_test == 4:
                
                # Check if the field is a unit field
                if child.tag == 'unit' and child.text is not None:
                    original_value = child.text
                    
                    # Generate a random string that is not a valid unit
                    random_length = random.randint(3, 15)
                    random_string = ''.join(random.choices(string.ascii_letters + string.digits + string.punctuation, k=random_length))
                    child.text = random_string
                    
                    # Write the modified tree back to a file
                    index = index + 1
                    output_file = 'tmptqf/' + input_file + str(index)
                    tree.write(output_file, encoding="utf-8", xml_declaration=True)
                    print(f"Modified XML saved to {output_file}")
                    query_response = tucuxi_run.run_tucuxi_from_file(output_file)
                    print(f"Query status: {query_response.queryStatus.statusCode}")
                    print(f"Query statusLit: {query_response.queryStatus.statusCodeLit}")
                    print(f"Query description: {query_response.queryStatus.description}")
                    print(f"Query message: {query_response.queryStatus.message}")

                    # Back to normal
                    child.text = original_value
                    
            elif type_of_test == 5:
                
                # Check if the field is a unit field and swap weight/concentration units
                if child.tag == 'unit' and child.text is not None:
                    original_value = child.text
                    
                    # Define the unit conversions
                    unit_conversions = {
                        'kg': 'kg/l',
                        'mg': 'mg/l',
                        'mg/l': 'mg'
                    }
                    
                    # Check if the unit needs to be converted
                    if original_value in unit_conversions:
                        child.text = unit_conversions[original_value]
                        
                        # Write the modified tree back to a file
                        index = index + 1
                        output_file = 'tmptqf/' + input_file + str(index)
                        tree.write(output_file, encoding="utf-8", xml_declaration=True)
                        print(f"Modified XML saved to {output_file}")
                        query_response = tucuxi_run.run_tucuxi_from_file(output_file)
                        print(f"Query status: {query_response.queryStatus.statusCode}")
                        print(f"Query statusLit: {query_response.queryStatus.statusCodeLit}")
                        print(f"Query description: {query_response.queryStatus.description}")
                        print(f"Query message: {query_response.queryStatus.message}")

                        # Back to normal
                        child.text = original_value
                        
                # Recurse into child elements
            process_element(child)

    # Process the root element
    process_element(root)


try:
    mkdir('tmptqf')
except:
    pass

modify_integers_to_negative_and_test('imatinib.tqf', 1)
print("\n\n=== Testing with random unit fields ===\n")
modify_integers_to_negative_and_test('imatinib.tqf', 4)
print("\n\n=== Testing with swapped weight/concentration units ===\n")
modify_integers_to_negative_and_test('imatinib.tqf', 5)

