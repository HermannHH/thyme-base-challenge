require 'digest/md5'
require 'nokogiri'

class Parser

  attr_reader :text, :highlight_hashes

  def initialize(text:, highlight_hashes:)
    @text = text
    @highlight_hashes = highlight_hashes
  end


  def call
    html = Nokogiri::HTML::DocumentFragment.parse(wrap_text).to_html
    File.write('index.html', html)
  end


  private

  def generate_color(hash)
    "##{Digest::MD5.hexdigest(hash.to_s)[0..5]}"
  end

  def paint_highlight_hashes
    highlight_hashes.map {|h|
      { start: h[:start], end: h[:end], comment: h[:comment], color: generate_color(h)}
    }
  end

  def sanitized_string
    text.strip.gsub(/[ ]{2,}/, '')
  end

  def entities
    sanitized_string.lines.map(&:chomp).map { |x| x.empty? ? "" : x.split(/(?<=[\s])/) }.flatten
  end

  def line_breaks
    entities.each_with_index.map { |item, index| index if item.empty? }.compact
  end

  def apply_highlight_tags
    words = entities.select { |entity| entity != "" }
    paint_highlight_hashes.sort_by { |h| h[:start] }.map { |rule|
      inclusive_line_breaks = line_breaks.select {|z| z.between?(rule[:start], rule[:end])}.sort
      closing_index = (rule[:end] <= rule[:start]) ? rule[:start] : rule[:end] - 1
      # Spans line breaks
      unless inclusive_line_breaks.empty?
        inclusive_line_breaks.each do |ln|
          if ln == inclusive_line_breaks.first
            # Add closing before
            # Add opening on start
            words[rule[:start]] = "<mark title='#{rule[:comment]}' style='background-color: #{rule[:color]};'>" + words[rule[:start]]
            words[ln - 1] = words[ln - 1] + "</mark>"
          else
            # Add closing before
            # Add opening after
            words[ln] = "<mark title='#{rule[:comment]}' style='background-color: #{rule[:color]};'>" + words[ln]
            words[ln - 1] = words[ln - 1] + "</mark>"
          end

          # IF LAST LINE BREAK USE END ELSE ADD BEFORE LINE BREAK
          if ln == inclusive_line_breaks.last
            # Add closing on end
            # Add opening after

            words[ln] = "<mark title='#{rule[:comment]}' style='background-color: #{rule[:color]};'>" + words[ln]
            words[closing_index] = words[closing_index] + "</mark>"
          else
            # Add closing before
            # Add opening after
            words[ln] = "<mark title='#{rule[:comment]}' style='background-color: #{rule[:color]};'>" + words[ln]
            words[ln - 1] = words[ln - 1] + "</mark>"
          end
        end
      else
        words[rule[:start]] = "<mark title='#{rule[:comment]}' style='background-color: #{rule[:color]};'>" + words[rule[:start]]
        words[closing_index] = words[closing_index] + "</mark>"
      end

    }
    words
  end

  def full_text_array
    output = apply_highlight_tags
    line_breaks.each do |line|
      output.insert(line, "</p><p>")
    end
    output
  end

  def wrap_text
    "<p>#{full_text_array.join}</p>"
  end
end
