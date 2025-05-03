defmodule MarkdownEditorWeb.EditorLive do
  use MarkdownEditorWeb, :live_view
  alias MarkdownEditor.DocumentStore

  @impl true
  def mount(_params, _session, socket) do
    # Generate a unique session ID for this editor instance
    session_id = generate_session_id()

    if connected?(socket) do
      Phoenix.PubSub.subscribe(MarkdownEditor.PubSub, "markdown:#{session_id}")
    end

    initial_content = DocumentStore.get_document(session_id)

    {:ok,
     socket
     |> assign(:session_id, session_id)
     |> assign(:markdown_content, initial_content)
     |> assign(:copy_flash, nil)}
  end

  @impl true
  def handle_event("update_markdown", %{"markdown" => content}, socket) do
    session_id = socket.assigns.session_id
    DocumentStore.update_document(session_id, content)

    {:noreply, assign(socket, :markdown_content, content)}
  end

  @impl true
  def handle_event("copy_content", _, socket) do
    # We'll handle the copy action via JS on the client side
    # This just provides feedback that the copy action was triggered
    {:noreply, assign(socket, :copy_flash, "Content copied to clipboard!")}
  end

  @impl true
  def handle_info({:document_updated, content}, socket) do
    {:noreply, assign(socket, :markdown_content, content)}
  end

  defp generate_session_id do
    :crypto.strong_rand_bytes(16) |> Base.encode16(case: :lower)
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="container mx-auto p-4">
      <h1 class="text-2xl font-bold mb-4">Markdown Editor</h1>

      <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
        <!-- Left pane: Markdown input -->
        <div class="border rounded p-2">
          <h2 class="text-lg font-semibold mb-2">Edit Markdown</h2>
          <form phx-change="update_markdown" phx-submit="noop">
            <textarea
              name="markdown"
              id="markdown-input"
              rows="20"
              class="w-full p-2 font-mono border rounded"
              phx-debounce="300"
            ><%= @markdown_content %></textarea>
          </form>
        </div>
        
    <!-- Right pane: Rendered output -->
        <div class="border rounded p-2">
          <div class="flex justify-between items-center mb-2">
            <h2 class="text-lg font-semibold">Preview</h2>
            <div class="space-x-2">
              <button
                phx-click="copy_content"
                id="copy-button"
                class="px-3 py-1 bg-blue-500 text-white rounded"
                phx-hook="CopyToClipboard"
              >
                Copy
              </button>

              <button
                id="export-button"
                class="px-3 py-1 bg-green-500 text-white rounded"
                phx-hook="ExportToPDF"
              >
                Export PDF
              </button>
            </div>
          </div>

          <%= if @copy_flash do %>
            <div class="bg-green-100 border border-green-400 text-green-700 px-4 py-2 rounded mb-2">
              {@copy_flash}
            </div>
          <% end %>

          <div
            id="markdown-output"
            class="markdown-body p-4 border rounded bg-white overflow-auto"
            style="min-height: 400px;"
          >
            {Phoenix.HTML.raw(Earmark.as_html!(@markdown_content))}
          </div>
        </div>
      </div>
    </div>
    """
  end
end
