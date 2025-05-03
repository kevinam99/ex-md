defmodule MarkdownEditor.Repo do
  use Ecto.Repo,
    otp_app: :markdown_editor,
    adapter: Ecto.Adapters.Postgres
end
