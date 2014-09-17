module CarrierWave
  module Storage
    class TrueVault < Abstract
      def store!(file)
        f = CarrierWave::Storage::TrueVault::File.new(uploader, self, uploader.store_path(file))
        f.store(file)
        f
      end

      def retrieve!(file)
        CarrierWave::Storage::TrueVault::File.new(uploader, self, uploader.store_path(file))
      end

      private

      class File
        include CarrierWave::Utilities::Uri
      
        attr_reader :path
        attr_accessor :response

        def initialize(uploader, base, path)
          @uploader, @base, @path = uploader, base, path
          @response = {}
        end

        def store(file)
          truevault_file = file.to_file
          @response = client.create_blob(@uploader.truevault_vault_id, truevault_file)
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
          CarrierWave::TrueVault::Client.new(@uploader.truevault_api_key)
        end

        def file
          @file ||= client.get_blob(@uploader.truevault_vault_id, @response["blob_id"])
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
