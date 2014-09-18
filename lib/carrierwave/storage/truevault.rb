module CarrierWave
  module Storage
    class TrueVault < Abstract
      def store!(file)
        f = CarrierWave::Storage::TrueVault::File.new(uploader, self, uploader.store_path)
        f.store(file)
        f
      end

      def retrieve!(identifier)
        CarrierWave::Storage::TrueVault::File.new(uploader, self, uploader.store_path(identifier))
      end

      class File
        attr_accessor :blob_id, :blob_filename, :transaction_id

        ##
        # Return all attributes from file
        #
        # === Returns
        #
        # [Hash] attributes from file
        #
        def attributes
          @attributes || {}
        end

        def attributes=(attrs)
          @attributes = attrs
        end

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
          @uploader.truevault_attributes = @file.parsed_response
          truevault_file.close if truevault_file && !truevault_file.closed?
          true
        end

        private

        def model
          @uploader.model
        end

        def client
          CarrierWave::TrueVault::Client.new(@uploader.truevault_api_key)
        end

        def file
          tmp = client.get_blob(@uploader.truevault_vault_id, @blob_id)
          @file ||= IO.binread(tmp)
          @file
        end

      end
    end
  end
end
