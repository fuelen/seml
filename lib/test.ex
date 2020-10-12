defmodule Test do
  import EmailSystem

  def run(opts \\ []) do
    context = %{
      translate: %{
        warn_on_unknown_pattern: true
      },
      datetime: %{timezone: "Africa/Casablanca"},
      appearance: %{
        email_translations: %{
          "Hello %{name}!" => "Бардзо здравіє, %{name}!",
          "Let me show you what is the time in %{country}" => "У %{country} зараз"
        }
      }
    }

    {Seml.Compiler.compile(template(), context, EmailSystem.Compilers.HTML, opts),
     Seml.Compiler.compile(template(), context, EmailSystem.Compilers.Text, opts)}
  end

  def template do
    name = "John"
    country = "Costa Rica"
    datetime = ~U[2020-10-05 19:16:31.579497Z]
    someone_elses_timezone = "Pacific/Tarawa"

    layout do
      section width: 3 do
        column width: 1 do
          translate assigns: [name: name, country: country] do
            "Hello %{name}!"
            horizontal_line()
            "Let me show you what is the time in %{country}"

            time(value: ~T[15:47:08.021629], format: "%I:%M %p")

            horizontal_line()

            "your time"
            datetime(value: datetime)
            "someone else's"
            datetime(value: datetime, timezone: someone_elses_timezone)
          end
        end

        column width: 2 do
          "heeey"
          horizontal_line()
          "thanks"
        end
      end
    end
  end
end
