require_relative "spec_helper"

describe "discover" do
  def run(path)
    `docker compose run --rm -w /#{path} cmp discover`.chomp
  end

  context "supported structures" do
    %w[
      encrypted_file_in_folder
      encrypted_file_in_subfolder
      encrypted_file_in_shared_resource
      encrypted_file_in_shared_folder
      encrypted_file_in_shared_resource_of_shared_resource
    ].each do |base_path|
      context base_path do
        it "returns zero exit code and outputs a success message" do
          setup_file_structure(base_path) do |tmpdir|
            output = run(File.join(tmpdir, "application"))

            expect($?.exitstatus).to eq(0)
            expect(output).to include("is supported")
          end
        end
      end
    end
  end

  context "unsupported structures" do
    %w[
      no_encrypted_file
    ].each do |base_path|
      context base_path do
        it "returns non-zero exit code and outputs a error message" do
          setup_file_structure(base_path) do |tmpdir|
            output = run(tmpdir)

            expect($?.exitstatus).not_to eq(0)
            expect(output).to_not be_empty
          end
        end
      end
    end
  end
end
