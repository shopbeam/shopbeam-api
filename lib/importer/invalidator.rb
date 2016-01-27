module Importer
  class Invalidator
    class << self
      def by_time(start_time)
        Product.where('"validatedAt" < ?', start_time).update_all(status: 0)
        Variant.where('"validatedAt" < ?', start_time).update_all(status: 0)
        VariantImage.where('"validatedAt" < ?', start_time).update_all(status: 0)
        Brand.where('"validatedAt" < ?', start_time).update_all(status: 0)
        Partner.where('"validatedAt" < ?', start_time).update_all(status: 0)

        clear_legacy_filters
      end

      private
      #TODO: this is legacy shit. remove it after we get rid of spock
      def clear_legacy_filters
        sql = 'BEGIN;
          DROP TABLE IF EXISTS partnerfilters_inprocess;
          CREATE TABLE partnerfilters_inprocess AS
          SELECT CAST(\'partner\' AS VARCHAR(7)) AS filtertype,
            pt."name" AS filtername, MAX(pt."id") AS filterid
            FROM "Partner" pt
            WHERE pt."status" = 1
              AND EXISTS(
                SELECT 1
                FROM "Variant" v
                INNER JOIN "Product" p ON v."ProductId" = p."id" AND p."status" = 1
                INNER JOIN "Brand" b ON p."BrandId" = b."id" AND b."status" = 1
                WHERE b."PartnerId" = pt."id" AND v."status" = 1)
            GROUP BY pt."name"
            ORDER BY Upper(pt."name");
          DROP TABLE IF EXISTS partnerfilters;
          ALTER TABLE partnerfilters_inprocess RENAME TO partnerfilters;
          COMMIT;
          BEGIN;
          DROP TABLE IF EXISTS categoryfilters_inprocess;
          CREATE TABLE categoryfilters_inprocess AS
          SELECT CAST(\'category\' AS VARCHAR(7)) AS filtertype,
            c."name" AS filtername, MAX(c."id") AS filterid
            FROM "Category" c
            WHERE c."status" = 1
              AND EXISTS(
                SELECT 1
                FROM "Variant" v
                INNER JOIN "Product" p ON v."ProductId" = p."id" AND p."status" = 1
                INNER JOIN "Brand" b ON p."BrandId" = b."id" AND b."status" = 1
                INNER JOIN "Partner" par ON par."id" = b."PartnerId" AND par."status" = 1
                INNER JOIN "ProductCategory" pc ON pc."ProductId" = p."id" AND pc."status" = 1
                WHERE pc."CategoryId" = c."id" AND v."status" = 1)
            GROUP BY c."name"
            ORDER BY Upper(c."name");
          DROP TABLE IF EXISTS categoryfilters;
          ALTER TABLE categoryfilters_inprocess RENAME TO categoryfilters;
          COMMIT;
          BEGIN;
          DROP TABLE IF EXISTS brandfilters_inprocess;
          CREATE TABLE brandfilters_inprocess AS
          SELECT CAST(\'brand\' AS VARCHAR(7)) AS filtertype,
            b."name" AS filtername, b."id" AS filterid
            FROM "Brand" b
            WHERE EXISTS(
                SELECT 1
                FROM "Variant" v
                INNER JOIN "Product" p ON v."ProductId" = p."id" AND p."status" = 1
                INNER JOIN "Brand" b2 ON p."BrandId" = b2."id" AND b2."status" = 1
                INNER JOIN "Partner" par ON par."id" = b2."PartnerId" AND par."status" = 1
                WHERE p."BrandId" = b."id" AND v."status" = 1)
            ORDER BY Upper(b."name");
          DROP TABLE IF EXISTS brandfilters;
          ALTER TABLE brandfilters_inprocess RENAME TO brandfilters;
          COMMIT;'
        ActiveRecord::Base.connection.execute(sql)
      end
    end
  end
end
