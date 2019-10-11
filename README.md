# conjur_aws_lambda_example
Example AWS Lambda function that utilizes Conjur to retrieve secrets.

# Overview
This script will use the AWS_ACCESS_KEY and AWS_SECRET assigned to the role that is executing the function to authenticate the function with your Conjur instance and return a secret value. Note: You should already have an app defined and the auth_iam integration completed within Conjur. Additionally you should define a secret that the AWS Role assigned to the function is able to retrieve. For more information on that process refer to the following page: [Conjur Docs](https://docs.cyberark.com/Product-Doc/OnlineHelp/AAM-DAP/Latest/en/Content/Operations/Services/AWS_IAM_Authenticator.htm?tocpath=Integrations%7C_____10)

# Prerequisites
1. Lambda function defined that is assigned a role that is able to authenticate with your Conjur instance - See docs link above
2. Create an IAM Role, Trust Relationship, and Policy for the Lambda Function
  1. *you can use the scripts and json templates in the AWS-Policy folder to create a role with appropriate permissions*
3. Set the handler for your lambda function to: lambda_function.lambda_handler if it is not already set
4. Define the following Lambda function Environment Variables:
   1. *application_name* = The name of your defined application in Conjur (e.g. myapp)
   2. *authn_iam_service_id* = The name of your defined service id in Conjur (e.g. prod)
   3. *aws_iam_role* = The name of the role you created in AWS that can authenticate with Conjur (e.g. Conjur-Lambda-Role )
   4. *conjur_account* = The name of your Conjur Account
   5. *conjur_authn_login* = Your applicaion authn login string (e.g. host/<application_name>/<aws_account_number>/<aws_iam_role> or host/myapp/123456789123/Conjur-Lambda-Role)
   6. *conjur_cert_file* = The name of the certificate you uploaded (e.g. conjurcert.pem)
   7. *var_id* = The name of the variable you defined in Conjur (e.g. myapp/database/password)
* Note: Variables above are directly related to the authn-iam integration setup information provided by CyberArk

# Basic use case instructions
1. Clone this repository
2. Copy your conjur cert into this directory with the name you plan to assign in the lambda function Environment Variables (e.g. conjurcert.pem)
3. Run the following command from the directory: `bundle install --path vendor/bundle`
4. Zip the required contents for the function: `zip -r function.zip lambda_function.rb conjurcert.pem vendor`
5. Upload the zip to your lambda function: `aws lambda update-function-code --function-name Conjur-Lambda-Function --zip-file fileb://function.zip`
