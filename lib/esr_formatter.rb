require 'nokogiri'
require 'socket'
require 'time'

# Custom formatter implementation according to  https://www.rubydoc.info/gems/rspec-core/RSpec/Core/Formatters
class ESRFormatter
  RSpec::Core::Formatters.register self, :dump_summary

  def initialize(output)
    @output = output
  end

  STRIP_DIFF_COLORS_BLOCK_REGEXP = /^ ( [ ]* ) Diff: (?: \e\[ 0 m )? (?: \n \1 \e\[ \d+ (?: ; \d+ )* m .* )* /x.freeze
  STRIP_DIFF_COLORS_CODES_REGEXP = /\e\[ \d+ (?: ; \d+ )* m/x.freeze

  def strip_diff_colors(string)
    # XXX: RSpec diffs are appended to the message lines fairly early and will
    # contain ANSI escape codes for colorizing terminal output if the global
    # rspec configuration is turned on, regardless of which notification lines
    # we ask for. We need to strip the codes from the diff part of the message
    # for XML output here.
    #
    # We also only want to target the diff hunks because the failure message
    # itself might legitimately contain ansi escape codes.
    #
    string.sub(STRIP_DIFF_COLORS_BLOCK_REGEXP) { |match| match.gsub(STRIP_DIFF_COLORS_CODES_REGEXP, ''.freeze) }
  end

  def esc(str)
    # Deal with all special character that can confuse xml builder or parser
    strip_diff_colors(str.to_s).sub("\0", '\\\\0').sub("\e", '\\\\e').sub("\x01", '\\\\x01').sub("\uFFFF", '\\\\uFFFF')
  end

  def dump_summary(summary)
    builder = Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
      xml.testsuites do
        xml.testsuite('id' => 0,
                      'name' => 'rspec',
                      'package' => 'rspec',
                      'tests' => summary.example_count,
                      'successed' => summary.example_count - summary.failure_count - summary.pending_count,
                      'failures' => summary.failure_count,
                      'skipped' => summary.pending_count,
                      'errors' => 0,
                      'hostname' => Socket.gethostname,
                      'time' => format('%.6f', summary.duration),
                      'timestamp' => (Time.now - summary.duration).iso8601) do
          summary.examples.each do |example|
            xml.testcase('name' => esc(example.full_description),
                         'classname' => esc(example.example_group.described_class),
                         'time' => format('%.6f', example.execution_result.run_time)) do
              case example.execution_result.status
              when :passed
                xml.success
              when :failed
                error_msg = esc(example.execution_result.exception.to_s)
                xml.failure('type' => example.execution_result.exception.class,
                            'message' => error_msg) do
                  xml.text(error_msg)
                end
              when :pending
                xml.skipped
              end

              xml.properties do
                example.metadata.each do |k, v|
                  if !RSpec::Core::Metadata::RESERVED_KEYS.include?(k) && !%i[stdout stderr].include?(k)
                    xml.property('name' => k, 'value' => esc(v))
                  end
                end
              end

              xml.send('system-out') do
                xml.text(esc(example.metadata[:stdout]))
              end

              xml.send('system-err') do
                xml.text(esc(example.metadata[:stderr]))
              end
            end
          end
        end
      end
    end
    @output.puts builder.to_xml
  end
end
