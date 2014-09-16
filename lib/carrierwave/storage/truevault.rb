module CarrierWave
  module Storage
    class TrueVault < Abstract
      def store!(file)
        truevault_client.create_blob(@vault_id, file.to_file)
      end

      def retrieve!(file)
        CarrerWave::Storage::TrueVault::File.new(uploader, config, uploader.store_path(file), truevault_client)
      end

      def truevault_client
        @truevault_client ||= begin
          CarrierWave::TrueVault::Client.new(config[:truevault_api_key],
                                             config[:truevault_account_id],
                                             config[:truevault_api_version])
        end
      end

      private

      def config
        @config ||= {}

        @config[:truevault_api_key] ||= uploader.truevault_api_key
        @config[:truevault_account_id] ||= uploader.truevault_account_id
        @config[:truevault_api_version] ||= uploader.truevault_api_version
        @config[:truevault_vault_id] ||= uploader.truevault_vault_id

        @config
      end

      class File
        include CarrierWave::Utilities::Uri
        attr_reader :path

        def initialize(uploader, config, path, client)
          @uploader, @config, @path, @client = uploader, config, path, client
        end

      end
    end
  end
end
