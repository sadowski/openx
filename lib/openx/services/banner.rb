require 'date'

module OpenX
  module Services
    class Banner < Base
      LOCAL_SQL = 'sql'
      LOCAL_WEB = 'web'
      EXTERNAL  = 'url'
      HTML      = 'html'
      TEXT      = 'txt'

      RUNNING = 0
      PAUSED  = 1

      class << self
        def find(id, *args)
          if id == :all
            responses = remote.call(find_all, *args)
            response  = responses.first
            return [] unless response
            responses = [response]

            ### Annoying..  For some reason OpenX returns a linked list.
            ### Probably a bug....
            while response.key?('aImage')
              response = response.delete('aImage')
              break unless response
              responses << response
            end

            responses.map do |response|
              new(translate(response))
            end
          else
            response  = remote.call(find_one, id)
            new(translate(response))
          end
        end
      end

      # Translate our property names to OpenX property names
      openx_accessor  :name           => :bannerName,
                      :campaign_id    => :campaignId,
                      :id             => :bannerId,
                      :storage_type   => :storageType,
                      :file_name      => :fileName,
                      :image_url      => :imageURL,
                      :html_template  => :htmlTemplate,
                      :width          => :width,
                      :height         => :height,
                      :weight         => :weight,
                      :target         => :target,
                      :url            => :url,
                      :status         => :status,
                      :adserver       => :adserver,
                      :transparent    => :transparent,
                      :image          => :aImage,
                      :backup_image   => :aBackupImage,
                      # 'keyword' only supported by patched server
                      # as per https://developer.openx.org/jira/browse/OX-4779
                      # No averse effect when unsupported by server (returns nil)
                      :keyword        => :keyword,
                      :comments       => :comments

      has_one :campaign

      self.create   = 'ox.addBanner'
      self.update   = 'ox.modifyBanner'
      self.delete   = 'ox.deleteBanner'
      self.find_one = 'ox.getBanner'
      self.find_all = 'ox.getBannerListByCampaignId'

      def initialize(params = {})
        raise ArgumentError.new("Missing campaign_id") unless params[:campaign_id] || params[:campaign]
        params[:campaign_id] ||= params[:campaign].id
        super(params)
      end

      def statistics start_on = Date.today, end_on = Date.today, local_time_zone = true
        remote.call('ox.bannerDailyStatistics', self.id, start_on, end_on, local_time_zone)
      end

      def targeting
        raise "Banner must be saved" if new_record?
        remote.call('ox.getBannerTargeting', self.id).map do |line|
          TargetingRule.instantiate(line)
        end
      end

      def targeting=(rules)
        raise "Banner must be saved" if new_record?
        remote.call('ox.setBannerTargeting', self.id, rules)
      end
    end
  end
end
