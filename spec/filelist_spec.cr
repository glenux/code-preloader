
require "./spec_helper"
require "../src/cli"

alias FileList = CodePreloader::FileList

describe CodePreloader::FileList do

  it "can be created empty" do
    fl = FileList.new
  end

  it "can be created with a list of directories" do
    fl = FileList.new(["src/", "spec/"])
  end

  it "verifies that initial directories exists" do
    expect_raises(FileList::NotADirectory) do
      fl = FileList.new(["Alice", "Bob"])
    end
  end

  it "can append extra sources" do
    fl = FileList.new()
    fl.add "spec/"
  end

  it "verifies that appended directories exists" do
    fl = FileList.new()
    expect_raises(FileList::NotADirectory) do
      fl.add "Alice"
    end
  end

  it "accept adding reject filters" do
    fl = FileList.new()
    fl.reject { |item| !!(item =~ /name/) }
  end

  it "accept adding select filters" do
    fl = FileList.new()
    fl.select { |item| !!(item =~ /name/) }
  end

  it "enumerates the files" do
    fl = FileList.new()
    fl.add("spec/filelist_data")

    files = Dir["spec/filelist_data/*"]
    fl.each do |file|
      files.should contain(file)
      files = files - [file]
    end
    files.size.should eq(0)
  end

  it "doesn't enumerate duplicate files" do
    fl = FileList.new()
    fl.add("spec/filelist_data")
    fl.add("spec/filelist_data")

    files = [] of String
    fl.each do |file|
      files << file
    end
    files.size.should eq(files.uniq.size)
  end

  it "doesn't enumerate files filtered out by select" do
    fl = FileList.new()
    fl.add("spec/filelist_data")
    fl.select { |path| !!(path =~ /\.c$/) }

    files = Dir["spec/filelist_data/*.c"]
    fl.each do |file|
      files.should contain(file)
      files = files - [file]
    end
    files.size.should eq(0)
  end

  it "doesn't enumerate files filtered out by reject" do
    fl = FileList.new()
    fl.add("spec/filelist_data")
    fl.reject { |path| !!(path =~ /\.txt$/) }

    files = Dir["spec/filelist_data/*.c"]
    fl.each do |file|
      files.should contain(file)
      files = files - [file]
    end
    files.size.should eq(0)

  end

  it "export the files as an array" do
  end

  it "doesn't export duplicate files" do
  end

  it "doesn't export filtered out files" do
  end
end
