defmodule Kitto.Job.Error do
  defexception [:message]

  def exception(%{exception: e, job: job}) do
    import Exception

    file = Path.relative_to(job.definition.file, Kitto.root)
    message = """
    Job :#{job.name} failed to run.
    Defined in: #{format_file_line(file, job.definition.line)}
    Error: #{format_banner(:error, e)}
    Stacktrace: #{format_stacktrace(System.stacktrace)}
    """

    %Kitto.Job.Error{message: message}
  end
end
