defmodule Kitto.CompileAssetsTask do
  use Mix.Releases.Plugin

  def before_assembly(_) do
    info "[CompileAssetsTask] Compiling assets"

    case System.cmd("npm", ["run", "build"]) do
      {output, 0} ->
        info output
        nil
      {output, error_code} -> {:error, output, error_code}
    end
  end

  def before_assembly(_, _), do: before_assembly(nil)
  def after_assembly(%Release{} = _release), do: nil
  def after_assembly(_, _), do: nil
  def before_package(%Release{} = _release), do: nil
  def before_package(_, _), do: nil
  def after_package(%Release{} = _release), do: nil
  def after_package(_, _), do: nil
  def after_cleanup(%Release{} = _release), do: nil
end
