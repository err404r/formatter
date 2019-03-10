require "nokogiri"
require "socket"

class ESRFormater
  RSpec::Core::Formatters.register self, :dump_summary

  def initialize(output)
    @output = output
  end
  
  def dump_summary(summary)
    builder = Nokogiri::XML::Builder.new do |xml|
      xml.testsuites {
        xml.testsuite( "id" => 0,
                       "name" => "rspec",
                       "tests" => summary.example_count,
                       "successed" => summary.example_count - summary.failure_count - summary.pending_count,
                       "failures" => summary.failure_count,
                       "skipped" => summary.pending_count,
                       "errors" => 0,
                       "hostname" => Socket.gethostname,
                       "time" => "%.6f" % summary.duration
                     ) {
          summary.examples.each do |example|
            xml.testcase( "name" => example.description,
                          "classname" => example.example_group.described_class,
                          "time" => "%.6f" % example.execution_result.run_time
                        ) {
              xml.properties {
                example.metadata.each do |k, v|
                  if !RSpec::Core::Metadata::RESERVED_KEYS.include?(k)
                    xml.property( "name" => k, "value" => v )
                  end
                end
              }
              case example.execution_result.status
              when :passed
                xml.success
              when :failed
                xml.failure( "type" => example.execution_result.exception.class,
                             "message" => example.execution_result.exception.to_s )
              when :pending
                xml.skipped
              end
            }
          end
        }
      }
    end
    @output.puts builder.to_xml
  end
end
