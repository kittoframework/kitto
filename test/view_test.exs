defmodule Kitto.ViewTest do
  use ExUnit.Case, async: true
  use Plug.Test

  test "#render(template) renders layout with the given assigns" do
    html = "<div class=\"layout blue\"><h1>Hello from kitto</h1>\n\n</div>\n"

    assert Kitto.View.render("sample", color: "blue") == html
  end

  test "#render(template) renders template with the given assigns" do
    html = "<div class=\"layout green\"><h1>Hello from kitto</h1>" <>
           "\n\n  <h2>Hello from contributor</h2>\n\n</div>\n"
    assigns = [color: "green", user: "contributor"]

    assert Kitto.View.render("sample", assigns) == html
  end

  test "#exists?(template) when the template exists, returns true" do
    assert Kitto.View.exists?("sample")
  end

  test "#exists?(template) when the template does not exist, returns false" do
    refute Kitto.View.exists?("does_not_exist")
  end
end
