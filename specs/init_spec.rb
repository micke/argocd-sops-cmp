require_relative "spec_helper"

describe "init" do
  def run(path)
    `docker compose run --rm -w /#{path} cmp init`.chomp
  end

  context "encrypted_file_in_folder" do
    it "decrypts the encrypted files" do
      setup_file_structure("encrypted_file_in_folder") do |tmpdir|
        run(File.join(tmpdir, "application"))
        decrypted_content = File.read(File.join(tmpdir, "application", "foo.dec.yaml")).chomp

        expect(decrypted_content).to eq("secret: The earth is round")
      end
    end
  end

  context "encrypted_file_in_subfolder" do
    it "decrypts the encrypted files" do
      setup_file_structure("encrypted_file_in_subfolder") do |tmpdir|
        run(File.join(tmpdir, "application"))
        decrypted_content = File.read(File.join(tmpdir, "application", "foo", "foo.dec.yaml")).chomp

        expect(decrypted_content).to eq("secret: The earth is round")
      end
    end
  end

  context "encrypted_file_in_shared_resource" do
    it "decrypts the encrypted files" do
      setup_file_structure("encrypted_file_in_shared_resource") do |tmpdir|
        run(File.join(tmpdir, "application"))
        decrypted_content = File.read(File.join(tmpdir, "shared", "foo.dec.yaml")).chomp

        expect(decrypted_content).to eq("secret: The earth is round")
      end
    end
  end

  context "encrypted_file_in_shared_resource_of_shared_resource" do
    it "decrypts the encrypted files" do
      setup_file_structure("encrypted_file_in_shared_resource_of_shared_resource") do |tmpdir|
        run(File.join(tmpdir, "application"))
        decrypted_content = File.read(File.join(tmpdir, "shared", "cert", "cert.dec.crt")).chomp

        expect(decrypted_content).to eq("This is a decrypted certificate")
      end
    end
  end
end
