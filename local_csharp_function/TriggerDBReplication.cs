using System.Net;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Http;
using Microsoft.Extensions.Logging;
using Azure;
using Azure.Core;
using Azure.Identity;
using Azure.ResourceManager;
using Azure.ResourceManager.AppContainers;
using Azure.ResourceManager.AppContainers.Models;
using Azure.ResourceManager.Resources;

namespace local_csharp_function
{

    public class TriggerDBReplication
    {
        private readonly ILogger _logger;

        public TriggerDBReplication(ILoggerFactory loggerFactory)
        {
            _logger = loggerFactory.CreateLogger<TriggerDBReplication>();
        }

        [Function("TriggerDBReplication")]
        public HttpResponseData Run([HttpTrigger(AuthorizationLevel.Anonymous, "get", "post")] HttpRequestData req)
        {
            TokenCredential cred = new DefaultAzureCredential();
            // authenticate your client
            ArmClient client = new ArmClient(cred);

            string subscriptionId = "7bc876fd-c9fc-4674-a3cd-115f28068bbb";
            string resourceGroup = "RG-TEST";
            ResourceIdentifier resourceGroupResourceId = ResourceGroupResource.CreateResourceIdentifier(subscriptionId, resourceGroup);
            ResourceGroupResource resourceGroupResource = client.GetResourceGroupResource(resourceGroupResourceId);
            Response<ContainerAppJobResource> getContainerAppJob = resourceGroupResource.GetContainerAppJob("sample-job");
            ContainerAppJobResource sampleJob = getContainerAppJob.Value;


            // string jobName = "sample-job-two";
            // ContainerAppJobData data = new ContainerAppJobData(new AzureLocation("Australia East")){
            //     EnvironmentId = "/subscriptions/7bc876fd-c9fc-4674-a3cd-115f28068bbb/resourceGroups/rg/providers/Microsoft.App/managedEnvironments/managedEnvironment-RGTEST-9681",
            //     Configuration = new ContainerAppJobConfiguration(ContainerAppJobTriggerType.Manual, 10)
            //     {
            //         ReplicaRetryLimit = 10,
            //         ManualTriggerConfig = new JobConfigurationManualTriggerConfig()
            //         {
            //             ReplicaCompletionCount = 1,
            //             Parallelism = 4,
            //         },
            //     },
            //     Template = new ContainerAppJobTemplate()
            //     {
                    
            //     }
            // }

            ContainerAppJobData data = new ContainerAppJobData(new AzureLocation("Australia East"))
            {
                Template = new ContainerAppJobTemplate()
                {
                    Containers = new MyContainerAppContainer()
                    {
                        Env = new List<ContainerAppEnvironmentVariable>(){
                            new ContainerAppEnvironmentVariable(){
                                Name = "rashid",
                                Value = "10"
                            },
                            new ContainerAppEnvironmentVariable(){
                                Name = "legoma",
                                Value = "10"
                            }
                        }
                    }
                }

            };
            
            ArmOperation<ContainerAppJobExecutionBase> execBase = sampleJob.Start(WaitUntil.Started);

            var response = req.CreateResponse(HttpStatusCode.OK);
            response.Headers.Add("Content-Type", "text/plain; charset=utf-8");

            response.WriteString($"Execution context: {execBase}");

            return response;
        }
    }
}
