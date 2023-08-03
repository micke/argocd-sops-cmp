require "fileutils"
require "securerandom"
require "pry"
require "amazing_print"
require "open3"

AmazingPrint.pry!

def setup_file_structure(base_path)
  path = "tmp/#{SecureRandom.uuid}"

  FileUtils.cd(__dir__) do
    FileUtils.cp_r("fixtures/#{base_path}", path)
    FileUtils.chmod_R(0o777, path)

    yield path.dup
  end
ensure
  FileUtils.remove_entry(File.join(__dir__, path))
end
