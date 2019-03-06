class ESRFormater
  RSpec::Core::Formatters.register self, :dump_summary

  NOT_CUSTOM_KEYS = [ :block, :description_args, :description, :full_description, :described_class,
                      :file_path, :line_number, :location, :absolute_file_path, :rerun_file_path,
                      :scoped_id, :execution_result, :example_group, :last_run_status,
                      :shared_group_inclusion_backtrace ]

  def initialize(output)
    @output = output
  end
  
  def dump_summary(summary)
    @output << "Test suit statistic" << "\n"
    @output << "Duration:".ljust(20) << summary.formatted_duration << "\n"
    @output << "Test case summary" << "\n"
    @output << "Total:".ljust(20) << summary.example_count << "\n"
    @output << "Failed:".ljust(20) << summary.failure_count << "\n"
    @output << "Pending:".ljust(20) << summary.pending_count << "\n"
    @output << "Test case details" << "\n"

    for example in summary.examples
      @output << "  Description:".ljust(20) << example.description << "\n"
      @output << "    Status:".ljust(20) << example.execution_result.status << "\n"
      @output << "    Group:".ljust(20) << example.example_group.description << "\n"
      @output << "    Metadata:" << "\n"
      example.metadata.each do |k, v|
        if !NOT_CUSTOM_KEYS.include?(k)
          @output.puts "      #{k.to_s.ljust(12)} => #{v}"
        end
      end
    end
  end
end
