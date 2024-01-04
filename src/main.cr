require "./cli"

app = CodePreloader::Cli.new(ARGV)
app.exec()


