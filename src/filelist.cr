
require "walk"

module CodePreloader

  # Manage a list of files
  class FileList 

    alias Filter = String -> Bool

    class NotADirectory < Exception
      def initialize(path)
        super(path.to_s)
      end
    end

    @sources : Array(String)
    @filters_in : Array(Filter)
    @filters_out : Array(Filter)

    def initialize(dirs = [] of String)
      @sources = [] of String
      @filters_in = [] of Filter
      @filters_out = [] of Filter
      dirs.each { |dir| self.add(dir) }
    end

    def add(dirs : Array(String))
      dirs.each { |dir| add(dir) }
    end

    def add(dir : String)
      raise NotADirectory.new(dir) if !File.exists? dir

      @sources << dir
    end

    def select(&filter : Filter)
      @filters_in << filter
    end

    def reject(&filter : Filter)
      @filters_out << filter
    end

    def each(&block)
      # ensure we display files only once
      seen = Set(String).new

      # walk each source
      @sources.each do |dir|
        walker = Walk::Down.new(dir)

        walker = walker.filter do |path|
          is_dir = File.directory? path
          keep = true
          must_select = false
          must_reject = false

          @filters_in.each do |filter_in|
            must_select = must_select || filter_in.call(path.to_s)
          end
          keep = keep && must_select if @filters_in.any?
          keep = keep || is_dir

          @filters_out.each do |filter_out|
            must_reject = must_reject || filter_out.call(path.to_s)
          end
          keep = keep && !must_reject if @filters_out.any?

          keep
        end

        walker.each do |path|
          next if File.directory? path

          path = File.realpath(path) if File.symlink? path
          next if seen.includes? path.to_s

          seen << path.to_s
          yield path.to_s
        end
      end
    end

    def to_a()
      files = [] of String
      self.each do |path|
        files << path.to_s
      end
      files
    end
  end
end
