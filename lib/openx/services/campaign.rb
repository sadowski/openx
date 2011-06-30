module OpenX
  module Services
    class Campaign < Base
      # Translate our property names to OpenX property names
      openx_accessor  :name               => :campaignName,
                      :advertiser_id      => :advertiserId,
                      :id                 => :campaignId,
                      :start_date         => :startDate,
                      :end_date           => :endDate,
                      :impressions        => :impressions,
                      :target_impressions => :targetImpressions,
                      :target_clicks      => :targetClicks,
                      :revenue            => :revenue,
                      :revenue_type       => :revenueType,
                      :impressions        => :impressions,
                      :clicks             => :clicks,
                      :priority           => :priority,
                      :weight             => :weight,
                      :campaign_type      => :campaignType,
                      :comments           => :comments

      has_one :advertiser

      self.create   = 'ox.addCampaign'
      self.update   = 'ox.modifyCampaign'
      self.delete   = 'ox.deleteCampaign'
      self.find_one = 'ox.getCampaign'
      self.find_all = 'ox.getCampaignListByAdvertiserId'

      # Revenue types
      CPM             = 1
      CPC             = 2
      CPA             = 3
      MONTHLY_TENANCY = 4

      # Campaign types
      REMNANT   = 1
      HIGH      = 2
      EXCLUSIVE = 3

      def initialize(params = {})
        raise ArgumentError.new("Missing advertiser_id") unless params[:advertiser_id] || params[:advertiser]
        params[:advertiser_id] ||= params[:advertiser].id
        super(params)
      end

      def banners
        Banner.find(:all, self.id)
      end

      def publisher_statistics(start_on = Date.today, end_on = Date.today, local_time_zone = true)
	    remote.call('ox.campaignPublisherStatistics', self.id, start_on, end_on, local_time_zone)
      end

      def zone_statistics(start_on = Date.today, end_on = Date.today, local_time_zone = true)
        remote.call('ox.campaignZoneStatistics', self.id, start_on, end_on, local_time_zone)
      end
    end
  end
end
