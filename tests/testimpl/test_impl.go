package testimpl

import (
	"context"
	"io"
	"net/http"
	"testing"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/lambda"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/launchbynttdata/lcaf-component-terratest/types"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestComposableComplete(t *testing.T, ctx types.TestContext) {
	lambdaClient := GetAWSLambdaClient(t)

	functionArn := terraform.Output(t, ctx.TerratestTerraformOptions(), "lambda_function_arn")
	functionName := terraform.Output(t, ctx.TerratestTerraformOptions(), "lambda_function_name")
	functionUrl := terraform.Output(t, ctx.TerratestTerraformOptions(), "lambda_function_url")

	t.Run("TestLambdaFunctionExists", func(t *testing.T) {
		function, err := lambdaClient.GetFunction(context.TODO(), &lambda.GetFunctionInput{
			FunctionName: &functionName,
		})
		if err != nil {
			t.Errorf("Failure during GetFunction: %v", err)
		}

		assert.Equal(t, *function.Configuration.FunctionArn, functionArn, "Expected ARN did not match actual ARN!")
		assert.Equal(t, *function.Configuration.FunctionName, functionName, "Expected Name did not match actual Name!")
	})

	t.Run("InvokeExampleSourceFromFolder", func(t *testing.T) {
		ctx.EnabledOnlyForTests(t, "source_from_folder")

		resp, err := http.Get(functionUrl)
		if err != nil {
			t.Errorf("Failure during HTTP GET: %v", err)
		}

		defer resp.Body.Close()
		body, err := io.ReadAll(resp.Body)
		if err != nil {
			t.Errorf("Failure reading Body: %v", err)
		}

		assert.Contains(t, string(body), "examples/source_from_folder", "Body did not contain expected response!")
	})

	t.Run("InvokeExampleSourceFromZip", func(t *testing.T) {
		ctx.EnabledOnlyForTests(t, "source_from_zip")

		resp, err := http.Get(functionUrl)
		if err != nil {
			t.Errorf("Failure during HTTP GET: %v", err)
		}

		defer resp.Body.Close()
		body, err := io.ReadAll(resp.Body)
		if err != nil {
			t.Errorf("Failure reading Body: %v", err)
		}

		assert.Contains(t, string(body), "examples/source_from_zip", "Body did not contain expected response!")
	})
}

func GetAWSLambdaClient(t *testing.T) *lambda.Client {
	awsLambdaClient := lambda.NewFromConfig(GetAWSConfig(t))
	return awsLambdaClient
}

func GetAWSConfig(t *testing.T) (cfg aws.Config) {
	cfg, err := config.LoadDefaultConfig(context.TODO())
	require.NoErrorf(t, err, "unable to load SDK config, %v", err)
	return cfg
}
