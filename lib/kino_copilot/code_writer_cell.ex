defmodule KinoCopilot.CodeWriterCell do
  @moduledoc false

  use Kino.JS, assets_path: "lib/assets/code_writer_cell"
  use Kino.JS.Live
  use Kino.SmartCell, name: "AI Codewriter"

  @impl true
  def init(_attrs, ctx) do
    ctx =
      ctx
      |> assign(
        message: "",
        gpt_task: nil,
        loading: false
      )

    {:ok, ctx,
     editor: [
       attribute: "code",
       language: "elixir",
       default_source: "",
       placement: :top
     ]}
  end

  @impl true
  def handle_connect(ctx) do
    payload = %{
      message: ctx.assigns.message
    }

    {:ok, payload, ctx}
  end

  @impl true
  def handle_event("update_message", message, ctx) do
    ctx = assign(ctx, message: message)
    broadcast_event(ctx, "update_message", message)
    {:noreply, ctx}
  end

  @impl true
  def handle_event("submit_message", message, ctx) do
    cell_id = get_cell_id(ctx)
    livebook_pid = get_livebook_pid_for_cell(cell_id)
    code = get_current_code(livebook_pid, cell_id)

    if ctx.assigns.gpt_task == nil && message != "" do
      task =
        Task.async(fn ->
          call_gpt(message, code)
        end)

      ctx =
        ctx
        |> assign(
          gpt_task: task,
          message: "",
          loading: true
        )

      broadcast_event(ctx, "update_loading", true)
      broadcast_event(ctx, "update_message", "")

      {:noreply, ctx}
    else
      {:noreply, ctx}
    end
  end

  @impl true
  def handle_info({ref, code}, ctx) when ctx.assigns.gpt_task.ref == ref do
    ctx = ctx |> assign(gpt_task: nil, loading: false)
    cell_id = get_cell_id(ctx)
    livebook_pid = get_livebook_pid_for_cell(cell_id)
    current_revision = get_current_revision(livebook_pid, cell_id)
    update_editor(livebook_pid, cell_id, code, current_revision + 1)
    broadcast_event(ctx, "update_loading", false)
    {:noreply, ctx}
  end

  def handle_info(_, socket), do: {:noreply, socket}

  defp get_cell_id(ctx) do
    ctx
    |> get_in(
      [:__private__, :ref]
      |> Enum.map(&Access.key!(&1))
    )
  end

  defp get_livebook_pid_for_cell(cell_id) do
    livebook_pids =
      Node.list(:connected)
      |> Enum.flat_map(fn n ->
        :rpc.call(n, :erlang, :processes, [])
        |> Enum.map(fn pid ->
          info = :rpc.call(n, Process, :info, [pid])
          {pid, info}
        end)
        |> Enum.filter(fn {_pid, info} ->
          case info[:dictionary][:"$initial_call"] do
            {Livebook.Session, _, _} -> true
            _ -> false
          end
        end)
        |> Enum.map(fn {pid, _} -> pid end)
      end)

    livebook_pids
    |> Enum.find(fn pid ->
      :sys.get_state(pid)
      |> get_in(
        [:data, :cell_infos]
        |> Enum.map(&Access.key!(&1))
      )
      |> Map.get(cell_id, false)
    end)
  end

  defp get_current_revision(livebook_pid, cell_id) do
    :sys.get_state(livebook_pid)
    |> get_in(
      [:data, :cell_infos, cell_id, :sources, :secondary, :revision]
      |> Enum.map(&Access.key!(&1))
    )
  end

  defp update_editor(livebook_pid, cell_id, code, revision) do
    GenServer.cast(
      livebook_pid,
      {:apply_cell_delta, self(), cell_id, :secondary,
       %{
         :ops => [
           {:delete, 9999},
           {:insert, code}
         ],
         ~c"__struct__" => "Elixir.Livebook.Delta"
       }, revision}
    )
  end

  defp get_current_code(livebook_pid, cell_id) do
    :sys.get_state(livebook_pid)
    |> get_in(
      [:data, :notebook, :sections]
      |> Enum.map(&Access.key!(&1))
    )
    |> Enum.flat_map(&Map.get(&1, :cells))
    |> Enum.find(&(Map.get(&1, :id) == cell_id))
    |> Map.get(:source)
  end

  @impl true
  def to_attrs(ctx) do
    %{
      "message" => ctx.assigns.message
    }
  end

  @impl true
  def to_source(attrs) do
    code = attrs["code"]
    code
  end

  def call_gpt(user_query, code \\ nil) do
    func = "run_elixir"
    model = Application.get_env(:kino_copilot, :default_model, "gpt-3.5-turbo")

    {:ok, resp} =
      OpenAI.chat_completion(
        model: model,
        messages:
          [
            %{
              role: "system",
              content:
                "You are an Senior Elixir developer whos job it is to write the correct code to answer the users questions."
            },
            if(code != nil,
              do: %{
                role: "system",
                content:
                  "The current code being edited is:\n\n<code lang=\"elixir\">#{code}</code>\n\n When answering the question, do not change existing modules and functions unless explicitly instructed, favor adding code and changing implementations."
              }
            ),
            %{role: "user", content: user_query}
          ]
          |> Enum.filter(& &1),
        function_call: %{name: func},
        functions: [
          %{
            name: func,
            description: "Report back valid elixir code to the user to be run.",
            parameters: %{
              type: "object",
              properties: %{
                code: %{
                  type: "string",
                  description: "Valid elixir code with newlines properly delimited"
                }
              }
            }
          }
        ]
      )

    %{
      choices: [
        %{
          "finish_reason" => "stop",
          "message" => %{
            "function_call" => %{
              "arguments" => arguments,
              "name" => ^func
            }
          }
        }
      ]
    } = resp

    IO.inspect(arguments)

    # You would think JSON decoding is the right solution here, but you'd be wrong.
    code =
      arguments
      |> String.replace(~r"{\s*\"code\"\s*:\s*\"+", "")
      |> String.replace_suffix("}", "")
      |> String.replace_trailing("\n", "")
      |> String.replace_trailing(" ", "")
      |> String.replace_suffix("\"", "")
      |> String.replace("\\\"", "\"")
      |> String.replace("\\n", "\n")

    code
    |> Code.format_string!()
    |> IO.iodata_to_binary()
  end
end
