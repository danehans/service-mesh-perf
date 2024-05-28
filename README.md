# Introduction

Service meshes provide essential capabilities for managing microservices traffic, including security, observability, and traffic management. However, these features often come with performance trade-offs. In this blog post, we will explore the performance impact of different service mesh configurations on our multi-tiered application. Specifically, we will compare [Linkerd](https://linkerd.io/) and [Istio](https://istio.io/) in both sidecar and ambient modes.

[TODO] Should Cilium service mesh be included in the comparison?

## Test Environment

Our 3-tiered application was deployed across 50 namespaces in a [GKE](https://cloud.google.com/kubernetes-engine) Kubernetes cluster. To generate consistent and realistic load, we used the [Vegeta](https://github.com/tsenart/vegeta) load generator, with each namespace deploying a separate load generator targeting the frontend, e.g. tier-1, of the test application. The load generator was configured as follows:

* Instance Type: n2-standard-8 spot instances in autoscaling mode
* Load Rate: 450 RPS per namespace, resulting in a total of ~112,500 RPS for the entire mesh
* Resource Requests and Limits: CPU - 500m, Memory - 300Mi (guaranteed QoS)

## Baseline Performance

Before deploying any service mesh, we measured the baseline performance of our application:

* P50 Latency: 1.57ms
* P95 Latency: 1.82ms

These baseline measurements serve as the foundation for evaluating the overhead introduced by each service mesh configuration.

## Performance Results

We tested three different configurations: Linkerd, Istio in sidecar mode, and Istio in ambient mode. Here are the results:

### Linkerd

Linkerd adds a lightweight data plane to handle mTLS and other features. Here’s the additional latency introduced by Linkerd:

* P50 Latency: 2.91ms
* P95 Latency: 3.37ms

### Istio in Sidecar Mode

Istio in sidecar mode provides both L4 and L7 features, including mTLS. This configuration introduced the following latencies:

* P50 Latency: 4.81ms
* P95 Latency: 5.72ms

### Istio in Ambient Mode

Ambient mode is a newer approach designed to reduce the overhead associated with the sidecar pattern. We tested two scenarios in ambient mode:

L4 mTLS Only:

* P50 Latency: 0.79ms
* P95 Latency: 0.85ms

L4 mTLS + L4 Mutual Auth:

* P50 Latency: 0.97ms
* P95 Latency: 1.07ms

### Visualizing the Results

Below is a graph summarizing the latency impacts of each configuration:

![Service Mesh Latency Comparison](images/gke-450rps.png)

## Analysis

From our tests, Istio in ambient mode clearly demonstrates superior performance compared to the sidecar approach, especially when only L4 mTLS is required. The latency overhead is minimal, making it a viable option for performance-sensitive applications.

## Conclusion

Choosing the right service mesh configuration depends on your specific needs and performance requirements. Ambient mode shows promising results, significantly reducing the latency overhead compared to traditional sidecar deployments. However, for comprehensive L4/L7 features, the sidecar mode is still relevant despite the higher latency.

For detailed test configurations and additional insights, please visit our [GitHub repository](https://github.com/solo-io/service-mesh-for-less-blog/tree/main).
