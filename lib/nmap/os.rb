require 'nmap/os_class'
require 'nmap/os_match'

module Nmap
  #
  # Wraps the `os` XML element.
  #
  class OS

    include Enumerable

    #
    # Creates a new OS object.
    #
    # @param [Nokogiri::XML::Node] node
    #   The node that contains the OS guessing information.
    #
    # @yield [os]
    #   If a block is given, it will passed the newly created OS object.
    #
    # @yieldparam [OS] os
    #   The newly created OS object.
    #
    def initialize(node)
      @node = node

      yield self if block_given?
    end

    #
    # Parses the OS class information.
    #
    # @yield [class]
    #   Passes each OS class to the given block.
    #
    # @yieldparam [OSClass] class
    #   The OS class information.
    #
    # @return [OS, Enumerator]
    #   The OS information. If no block was given, an enumerator object
    #   will be returned.
    #
    def each_class
      return enum_for(__method__) unless block_given?

      @node.xpath("osmatch/osclass").map do |osclass|
        os_class = OSClass.new(
          osclass['type'].to_sym,
          osclass['vendor'],
          osclass['osfamily'].to_sym,
          osclass['osgen'].to_sym,
          osclass['accuracy'].to_i
        )

        yield os_class
      end

      return self
    end

    #
    # Parses the OS class information.
    #
    # @return [Array<OSClass>]
    #   The OS class information.
    #
    def classes
      each_class.to_a
    end

    #
    # Parses the OS match information.
    #
    # @yield [match]
    #   Passes each OS match to the given block.
    #
    # @yieldparam [OSMatch] class
    #   The OS match information.
    #
    # @return [OS, Enumerator]
    #   The OS information. If no block was given, an enumerator object
    #   will be returned.
    #
    def each_match
      return enum_for(__method__) unless block_given?

      @node.xpath("osmatch").map do |osclass|
        os_match = OSMatch.new(
          osclass['name'],
          osclass['accuracy'].to_i
        )

        yield os_match
      end

      return self
    end

    #
    # Parses the OS match information.
    #
    # @return [Array<OSMatch>]
    #   The OS match information.
    #
    def matches
      each_match.to_a
    end

    #
    # Parses the ports used for guessing the OS.
    #
    # @return [Array<Integer>]
    #   The ports used.
    #
    def ports_used
      @ports_used ||= @node.xpath("portused/@portid").map do |port|
        port.inner_text.to_i
      end
    end

    #
    # Parses the OS fingerprint used by Nmap.
    #
    # @return [String]
    #   The OS fingerprint.
    #
    def fingerprint
      @fingerprint ||= @node.at("osfingerprint/@fingerprint").inner_text
    end

    #
    # Parses the OS match information.
    #
    # @see each_match
    #
    def each(&block)
      each_match(&block)
    end

  end
end
