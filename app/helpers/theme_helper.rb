module ThemeHelper
  def readable_text_color(hex_color)
    channels = hex_color.delete_prefix("#").scan(/../).map do |pair|
      component = pair.to_i(16) / 255.0
      component <= 0.04045 ? component / 12.92 : ((component + 0.055) / 1.055)**2.4
    end
    luminance = (0.2126 * channels[0]) + (0.7152 * channels[1]) + (0.0722 * channels[2])

    black_contrast = (luminance + 0.05) / 0.05
    white_contrast = 1.05 / (luminance + 0.05)
    black_contrast >= white_contrast ? "#000000" : "#FFFFFF"
  end
end
