
# vim: set ts=2 sw=2 et ft=crystal:

require "./cli"

# Now that we have checked for nil, it's safe to use not_nil!
app = CodePreloader::Cli.new
app.parse_arguments(ARGV)
app.exec()


