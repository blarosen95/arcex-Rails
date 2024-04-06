class BootstrapEmail::Compiler
    def perform_full_compile
      compile_html!
      inline_css!
      inject_head!
      inject_arcex_head!
      update_mailer!
    end
  
    def inject_arcex_head!
      @doc.at_css('head').add_child(arcex_email_head)
    end
  
    private
  
    def arcex_email_head
      engine = defined?(SassC::Engine).nil? ? Sass::Engine : SassC::Engine
      <<-HEREDOC
          <style type="text/css">
            #{
        engine.new(
          File.open(File.expand_path("#{Rails.root}/app/assets/stylesheets/bootstrap_email.scss", __dir__)).read,
          { syntax: :scss, style: :compressed, cache: false, read_cache: false },
        ).render
      }
          </style>
        HEREDOC
    end
  end