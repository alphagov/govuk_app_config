require "spec_helper"
require "govuk_app_config/govuk_i18n"

RSpec.describe GovukI18n do
  describe ".configure" do
    context "locale files exist" do
      let(:govuk_i18n_locale_path_stubs) { ["/lib/govuk_app_config/govuk_i18n/my_locale.yml", "/lib/govuk_app_config/govuk_i18n/my_other_locale.yml"] }

      before { allow(Dir).to receive(:[]).and_return(govuk_i18n_locale_path_stubs) }

      after { I18n.load_path = nil }

      it "adds govuk_app_config locales files to the i18n loadpath if explicity configured" do
        GovukI18n.configure

        govuk_i18n_locale_path_stubs.each do |file_path|
          expect(I18n.load_path).to include(file_path)
        end
      end

      it "does not add govuk_app_config translation files to the loadpath by default" do
        govuk_i18n_locale_path_stubs.each do |file_path|
          expect(I18n.load_path).not_to include(file_path)
        end
      end
    end

    context "locale files do not exist" do
      let(:govuk_i18n_locale_path_stubs) { [] }

      before do
        allow(Dir).to receive(:[]).and_return(govuk_i18n_locale_path_stubs)
      end

      it "doesn't mind if apps are configured to import translations but there are none available" do
        expect { GovukI18n.configure }.not_to(change { I18n.load_path })
      end
    end
  end
end
