create table routes
(
    id       varchar(255) not null
        primary key,
    name     varchar(255) null,
    type     int          null,
    is_night int          null
);
