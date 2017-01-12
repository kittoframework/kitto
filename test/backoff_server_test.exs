defmodule Kitto.BackoffServerTest do
  use ExUnit.Case, async: true

  alias Kitto.BackoffServer, as: Subject

  @min 1

  setup do
    Subject.reset

    on_exit fn ->
      Application.delete_env :kitto, :job_min_backoff
      Application.delete_env :kitto, :job_max_backoff
    end
  end

  test "#succeed resets to 0 the backoff for a job" do
    Subject.succeed :italian_job

    assert Subject.get(:italian_job) == 0
  end

  test "#reset resets the state of the server to an empty map" do
    Subject.fail :failjob
    Subject.fail :otherjob
    Subject.succeed :successjob

    Subject.reset

    assert is_nil(Subject.get(:failjob))
    assert is_nil(Subject.get(:otherjob))
    assert is_nil(Subject.get(:successjob))
  end

  test "#fail increases the backoff value exponentially (power of 2)" do
    Subject.fail :failjob

    val = Subject.get :failjob

    Subject.fail :failjob
    assert Subject.get(:failjob) == val * 2

    Subject.fail :failjob
    assert Subject.get(:failjob) == val * 4
  end

  test "#backoff! puts the current process to sleep for backoff time" do
    maxval = 100
    Application.put_env :kitto, :job_mix_backoff, 64
    Application.put_env :kitto, :job_max_backoff, maxval
    Subject.fail :failjob

    {time, _} = :timer.tc fn -> Subject.backoff! :failjob end

    assert_in_delta time / 1000, maxval, 5
  end

  describe "when :job_min_backoff is configured" do
    setup [:set_job_min_backoff]

    test "#fail initializes the backoff to the min value" do
      Subject.fail :failjob

      assert Subject.get(:failjob) == @min
    end
  end

  describe "when :job_min_backoff is not configured" do
    test "#fail initializes the backoff to the default min value" do
      Subject.fail :failjob

      assert Subject.get(:failjob) == Kitto.Time.mseconds(:second)
    end
  end

  defp set_job_min_backoff(_context) do
    Application.put_env :kitto, :job_min_backoff, @min
  end
end
