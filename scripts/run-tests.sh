#!/bin/bash

# Set the number of iterations to 1 if not provided
iterations=${1:-1}
testname=${NAME:-"$(date +%s)-test-run"}

run_test() {
  local rps=$1
  local connections=$2
  local concurrency=$3
  local duration=$4
  local filename=$5
  local iteration=$6

  start=$(date +%s)
  sleep 120 # provide a quiet time before generating load.
  echo "Running load generator tests with --duration $duration --rps $rps --connections $connections --concurrency $concurrency (Iteration: $iteration)"
  kubectl exec $(kubectl get pods -l app=workload -o custom-columns=:.metadata.name --no-headers) -c benchmark -- nighthawk_client --duration $duration --rps $rps --connections $connections --concurrency $concurrency -v info http://baseline:9080/ --output-format fortio | tee ${testname}-run-${iteration}-${filename}-rps.json
  end=$(date +%s)
}

for ((i=1; i<=iterations; i++)); do
  #run_test 125 10 8 60 1000 $i
  #run_test 625 10 8 60 5000 $i
  #run_test 1250 10 8 60 10000 $i
  run_test 3750 10 8 60 30000 $i
done
