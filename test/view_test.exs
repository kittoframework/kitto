defmodule Kitto.ViewTest do
  use ExUnit.Case, async: true
  use Plug.Test

  describe ".render/1" do
    test "renders layout with the given assigns" do
      html = "<div class=\"layout blue\"><h1>Hello from kitto</h1>\n\n</div>\n"

      assert Kitto.View.render("sample", color: "blue") == html
    end

    test "renders template with the given assigns" do
      html =
        "<div class=\"layout green\"><h1>Hello from kitto</h1>" <>
          "\n\n  <h2>Hello from contributor</h2>\n\n</div>\n"

      assigns = [color: "green", user: "contributor"]

      assert Kitto.View.render("sample", assigns) == html
    end
  end

  describe ".exists?/1" do
    test "when the template exists, returns true" do
      assert Kitto.View.exists?("sample")
    end

    test "when the template does not exist, returns false" do
      refute Kitto.View.exists?("does_not_exist")
    end

    test "when the template is not in dashboards, returns false" do
      refute Kitto.View.exists?("../../../mix.exs")
      refute Kitto.View.exists?("/etc/passwd")
      refute Kitto.View.exists?("../../../mix.exs\0")
      refute Kitto.View.exists?("/etc/passwd\0")
    end
  end
end
