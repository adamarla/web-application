# encoding: utf-8

class ExcelUploader < CarrierWave::Uploader::Base

  # Include RMagick or MiniMagick support:
  # include CarrierWave::RMagick
  # include CarrierWave::MiniMagick

  # Choose what kind of storage to use for this uploader:
  storage :file
  # storage :fog

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    #"uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
    'public/uploads/excel'
  end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  # def default_url
  #   "/images/fallback/" + [version_name, "default.png"].compact.join('_')
  # end

  # Process files as they are uploaded:
  # process :scale => [200, 300]
  process :parse_and_store
  def parse_and_store
    school = School.find model.id
    sektion = school.sektions.order(:created_at).last # sektion created just before coming here
    book = Spreadsheet.open model.xls.current_path
    return false if book.nil?

    sheet = book.worksheet 0 # only look at the first worksheet/tab
    sheet.each do |row|
      first = row[0]
      last = row[1]
      name = last.blank? ? first : "#{first} #{last}"
      model.enroll name, nil, nil, sektion unless name.blank?
    end
  end
  #
  # def scale(width, height)
  #   # do something
  # end

  # Create different versions of your uploaded files:
  # version :thumb do
  #   process :scale => [50, 50]
  # end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  def extension_white_list
    %w(xls xlsx)
  end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  # def filename
  #   "something.jpg" if original_filename
  # end

end
