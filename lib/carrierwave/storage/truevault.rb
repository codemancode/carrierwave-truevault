module CarrierWave
  module Storage
    class TrueVault < Abstract
      def store!(file)
        f = CarrierWave::Storage::TrueVault::File.new(uploader, config, uploader.store_path(file))
        f.store(file)
      end

      def retrieve!(file)
        CarrierWave::Storage::TrueVault::File.new(uploader, config, uploader.store_path(file))
      end

      def truevault_client
        @truevault_client ||= begin
          CarrierWave::TrueVault::Client.new(config[:truevault_api_key])
        end
      end

      private

      def config
        @config ||= {}

        @config[:truevault_api_key] ||= uploader.truevault_api_key
        @config[:truevault_vault_id] ||= uploader.truevault_vault_id

        @config
      end

      class File
        include CarrierWave::Utilities::Uri
        attr_reader :path, :file

        def initialize(uploader, config, path)
          @uploader, @config, @path, @client = uploader, config, path
        end

        def store(file)
          @file = file.to_file
          client.create_blob(config[:truevault_vault_id], file.to_file)
        end

        ##
        # Return size of file body
        #
        # === Returns
        #
        # [Integer] size of file body
        #
        def size
          @file.content_length
        end

        ##
        # Read content of file from service
        #
        # === Returns
        #
        # [String] contents of file
        def read
          @file.body
        end

        private

        def client
          CarrierWave::TrueVault::Client.new(config[:truevault_api_key])
        end

      end
    end
  end
end
