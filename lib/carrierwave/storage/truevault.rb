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
        include CarrierWave::Utilities::Uri
        ##
        # Current local path to file
        #
        # === Returns
        #
        # [String] a path to file
        #
        attr_reader :path

        attr_accessor :blob_id, :blob_filename, :transaction_id

        ##
        # Return all attributes from file
        #
        # === Returns
        #
        # [Hash] attributes from file
        #
        def attributes
          file.attributes
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
          file.body
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
          response = client.create_blob(@uploader.truevault_vault_id, truevault_file)
          raise TrueVaultStoreError, "TrueVaultStoreError", response
          @blob_id ||= response["blob_id"]
          @blob_filename ||= response["blob_filename"]
          truevault_file.close if truevault_file && !truevault_file.closed?
          true
        end

        class TrueVaultStoreError < Exception; end

        private

        def client
          CarrierWave::TrueVault::Client.new(@uploader.truevault_api_key)
        end

        def file
          @file ||= client.get_blob(@uploader.truevault_vault_id, @blob_id)
          tmp = Tempfile.new(@blob_filename)
          tmp.binmode
          tmp.write(body)
          tmp.rewind
          tmp
        end

      end
    end
  end
end
