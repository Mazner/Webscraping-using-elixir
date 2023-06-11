defmodule Webscrap do
  def get_manga do
    IO.puts("Executando...")

    reiniciar_arquivo("Em_alta.txt")

    case HTTPoison.get("https://lermanga.org/") do
      {:ok, %HTTPoison.Response{body: body}} ->
        IO.puts ("Procurando os titulos...")
        content = body
        titles = Floki.find(content, "div.sidebarhome h3.film-name a")
                  |> Enum.map(&Floki.text/1)
        IO.puts ("Procurando os links...")
        IO.puts ("Recuperando as sinopses...")
        Enum.each(titles, &print_manga_info/1)
    end

    IO.puts("Scrap finalizado, cheque o arquivo: \"Em_alta.txt\"")
  end

  defp reiniciar_arquivo(arquivo) do
    IO.puts ("Reiniciando o arquivo de saida...")
    case File.rm(arquivo) do
      :ok -> IO.puts ("Arquivo reinicializado com sucesso!")
      {:error, :enoent} -> :ok  # Caso o arquivo não exista, ele já está reiniciado.
      {:error, erro} -> raise "Arquivo não deletado!: #{erro}"
    end
  end

  defp print_manga_info(title) do
    title_str = "Titulo: #{title}"
    escrever_arquivo(title_str)

    link = "https://lermanga.org/mangas/#{String.replace(title, " ", "-")}/"
    link_str = "Link: #{link}"
    escrever_arquivo(link_str)

    case HTTPoison.get(link) do
      {:ok, %HTTPoison.Response{body: body}} ->
        content2 = body
        synopses = Floki.find(content2, "div.boxAnimeSobreLast p")
                   |> Enum.map(&Floki.text/1)

        Enum.each(synopses, &print_sinopse/1)
    end
  end

  defp print_sinopse(sinopse) do
    sinopse_str = "sinopse: #{sinopse}"
    escrever_arquivo(sinopse_str)
  end

  defp escrever_arquivo(content) do
    File.write("Em_alta.txt", content <> "\n", [:append])
  end
end
