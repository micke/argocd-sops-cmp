require_relative "spec_helper"

describe "generate" do
  def run(path, env)
    stdout, stderr, status = Open3.capture3("docker compose run --rm -w /#{path} #{env} cmp generate")

    [stdout.chomp, stderr.chomp, status]
  end

  let(:successful_output) { <<-YAML.chomp }
apiVersion: apps/v1
kind: Deployment
metadata:
  name: overprovisioning
  namespace: kube-system
spec:
  replicas: 1
  revisionHistoryLimit: 0
  template:
    spec:
      containers:
      - image: k8s.gcr.io/pause
        name: reserve-resources
  YAML

  context "not explicitly setting kustomize version" do
    let(:env) { "" }

    context "it uses the latest kustomize version" do
      it "returns zero exit code and outputs the manifest" do
        setup_file_structure("no_encrypted_file") do |tmpdir|
          working_directory = File.join(tmpdir, "application")
          stdout, stderr, status = run(working_directory, env)

          expect(status).to eq(0)
          expect(stderr).to be_empty
          expect(stdout).to eq(successful_output)
        end
      end
    end
  end

  context "requesting a unsupported kustomize version" do
    let(:env) { "-e ARGOCD_ENV_KUSTOMIZE_VERSION=9.9.9" }

    it "returns non-zero exit code and outputs a error message" do
      setup_file_structure("no_encrypted_file") do |tmpdir|
        working_directory = File.join(tmpdir, "application")
        _stdout, stderr, status = run(working_directory, env)

        expect(status).not_to eq(0)
        expect(stderr).to include("kustomize-9.9.9: command not found")
      end
    end
  end

  context "requesting a supported kustomize version" do
    let(:env) { "-e ARGOCD_ENV_KUSTOMIZE_VERSION=5.0.3" }

    it "returns zero exit code and outputs the manifest" do
      setup_file_structure("no_encrypted_file") do |tmpdir|
        working_directory = File.join(tmpdir, "application")
        stdout, stderr, status = run(working_directory, env)

        expect(status).to eq(0)
        expect(stderr).to be_empty
        expect(stdout).to eq(successful_output)
      end
    end
  end

  context "building a broken manifest" do
    let(:env) { "" }

    it "returns non-zero exit code and outputs a error message" do
      setup_file_structure("broken_manifest") do |tmpdir|
        working_directory = File.join(tmpdir, "application")
        _stdout, stderr, status = run(working_directory, env)

        expect(status).not_to eq(0)
        expect(stderr).to include("err='accumulating resources from 'deployments.yaml'")
      end
    end
  end
end
