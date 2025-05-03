defmodule MarkdownEditor.DocumentStore do
  @moduledoc """
  Agent-based state management for storing markdown documents
  """

  @doc """
  Get the markdown content for a specific session
  """
  def get_document(session_id) do
    Agent.get(MarkdownEditor.DocumentStore, fn state ->
      Map.get(state, session_id, "")
    end)
  end

  @doc """
  Update the markdown content for a specific session
  """
  def update_document(session_id, content) do
    Agent.update(MarkdownEditor.DocumentStore, fn state ->
      Map.put(state, session_id, content)
    end)

    # Broadcast the update to all clients subscribed to this session
    Phoenix.PubSub.broadcast(
      MarkdownEditor.PubSub,
      "markdown:#{session_id}",
      {:document_updated, content}
    )
  end
end
