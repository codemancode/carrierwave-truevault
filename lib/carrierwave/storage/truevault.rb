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
        attr_reader :path
        attr_accessor :response

        def initialize(uploader, config, path)
          @uploader, @config, @path = uploader, config, path
        end

        def store(file)
          @response = client.create_blob(config[:truevault_vault_id], file.to_file)
        end

        def size
          file.content_length
        end

        def read
          file.body
        end

        def filename
          @response["blob_filename"]
        end

        def file_id
          @response["blob_id"]
        end

        def transaction_id
          @response["transaction_id"]
        end

        private

        def client
          CarrierWave::TrueVault::Client.new(config[:truevault_api_key])
        end

        def file
          @file ||= client.get_blob(config[:truevault_vault_id], @response["blob_id"])
          tmp = Tempfile.new('blob')
          tmp.binmode
          tmp.write(body)
          tmp.rewind
          tmp
        end

      end
    end
  end
end
