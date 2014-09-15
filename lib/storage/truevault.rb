module CarrierWave
  module Storage
    class TrueVault < Abstract
      # Stubs we must implement to create and save files
      
      def store!(file)

      end

      def retrieve!(file)

      end

      def truevault_client

      end

      private

      def config
        @config ||= {}
      end

      class File
        include CarrierWave::Utilities::Uri
        attr_reader :path

        def initialize(uploader, config, path, client)
          @uploader, @config, @path, @client = uploader, config, path, client
        end

        def url
          @client.media(@path)["url"]
        end

        def delete
          path = @path
          path = "/#{path}" if @config[:access_type] == "truevault"
          begin
            @client.file_delete(path)
          rescue TrueVaultError
          end
        end
      end
    end
  end
end
