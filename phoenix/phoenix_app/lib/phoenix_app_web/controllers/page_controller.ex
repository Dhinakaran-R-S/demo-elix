defmodule PhoenixAppWeb.PageController do
  use PhoenixAppWeb, :controller
  alias PhoenixApp.LongText

  def home(conn, _params) do
    word_counts = LongText.count_words()
    render(conn, :home, word_counts: word_counts)
  end
end
