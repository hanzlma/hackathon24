create table stops
(
    id            varchar(255) not null
        primary key,
    name          varchar(255) null,
    latitude      double       null,
    longitude     double       null,
    zone_id       varchar(255) null,
    wheelchair    tinyint(1)   null,
    platform_code varchar(255) null
);
