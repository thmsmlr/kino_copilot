defmodule KinoCopilot.CodeWriterCellTest do
  use ExUnit.Case

  alias KinoCopilot.CodeWriterCell

  test "parse_function_call handles triple quote" do
    response = "{\n  \"code\": \"\"\"\n  IO.puts(\"Hello world\")  \"\"\"\n}"

    assert "IO.puts(\"Hello world\")" =
             CodeWriterCell.parse_function_call(response) |> String.trim()
  end

  test "parse_function_call handles extra escaped quotes" do
    response = "{\n  \"code\": \"\n  IO.puts(\\\"Hello world\\\") \"\n}"

    assert "IO.puts(\"Hello world\")" =
             CodeWriterCell.parse_function_call(response) |> String.trim()
  end

  test "parse_function_call handles extra unescaped quotes" do
    response = "{\n  \"code\": \"\n  IO.puts(\"Hello world\") \"\n}"

    assert "IO.puts(\"Hello world\")" =
             CodeWriterCell.parse_function_call(response) |> String.trim()
  end

  test "parse_function_call handles proper JSON response" do
    response = "{\n  \"code\": \"IO.puts(\\\"Hello world\\\")\"\n}"

    assert "IO.puts(\"Hello world\")" =
             CodeWriterCell.parse_function_call(response) |> String.trim()

    assert "IO.puts(\"Hello world\")" =
             Jason.decode!(response)["code"] |> String.trim()
  end
end
