module CarrierWave
  module Storage
    class TrueVault < Abstract
      def store!(file)
        f = CarrierWave::Storage::TrueVault::File.new(uploader, self, uploader.store_path)
        f.store(file)
        f
      end

      def retrieve!(identifier)
        f = CarrierWave::Storage::TrueVault::File.new(uploader, self, uploader.store_path(identifier))
        f.retrieve(identifier)
        f
      end

      class File
        ##
        # Lookup value for file content-type header
        #
        # === Returns
        #
        # [String] value of content-type
        #
        def content_type
          @content_type || file.content_type
        end

        ##
        # Set non-default content-type header (default is file.content_type)
        #
        # === Returns
        #
        # [String] returns new content type value
        #
        def content_type=(new_content_type)
          @content_type = new_content_type
        end

        def initialize(uploader, base, path)
          @uploader, @base, @path = uploader, base, path
        end

        ##
        # Read content of file from service
        #
        # === Returns
        #
        # [String] contents of file
        def read
          file
        end

        ##
        # Return size of file body
        #
        # === Returns
        #
        # [Integer] size of file body
        #
        def size
          file.content_length
        end

        def truevault_attributes
          attributes
        end

        ##
        # Write file to service
        #
        # === Returns
        #
        # [Boolean] true on success or raises error
        #
        def store(file)
          truevault_file = file.to_file
          @content_type ||= file.content_type
          @file = client.create_blob(@uploader.truevault_vault_id, truevault_file)
          @uploader.truevault_attributes.merge!(@file.parsed_response)
        end

        ##
        # Retrieve file from service
        #
        # === Returns
        #
        # [File]
        #
        def retrieve(identifier)
          @file = client.get_blob(@uploader.truevault_vault_id, model.blob_id)
          @file ||= File.open(@file.parsed_response)
        end

        private

        def model
          @uploader.model
        end

        def client
          CarrierWave::TrueVault::Client.new(@uploader.truevault_api_key)
        end

        def file
          tmp = client.get_blob(@uploader.truevault_vault_id, @uploader.truevault_attributes["blob_id"])
          @file ||= IO.binread(tmp)
          @file
        end

      end
    end
  end
end
