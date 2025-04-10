module GovukI18n
  GOVUK_APP_CONFIG_PATH = Gem.loaded_specs["govuk_app_config"].gem_dir

  def self.configure
    I18n.load_path += Dir[File.join(GOVUK_APP_CONFIG_PATH, "lib", "govuk_app_config", "govuk_i18n", "*.{yml}").to_s]
  end
end
