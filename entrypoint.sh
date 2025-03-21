#!/bin/bash

run_saber() {
    (
    echo "Running SABER job at $(date)"

    cd /home
    git pull

    python3 /home/saber.py -r /output/report.html -l /logs -s /configs/settings.yaml > /output/report.json 2>&1
    local exit_code=$?

    if [[ $exit_code -ne 0 && $exit_code -ne 42 ]]; then
        echo "SABER encountered an error (exit code: $exit_code), aborting..."
        return $exit_code 
    fi

    echo "Copying files to shared directory"
    current_date=$(date +%Y-%m-%d)
    current_time=$(date +%H:%M)

    cp /output/report.html /shared_data/www/report.html.new
    chmod 755 /shared_data/www/report.html.new
    mv /shared_data/www/report.html.new /shared_data/www/report.html
    
    cp /output/report.html /shared_data/www/index/report_${current_date}_${current_time}.html 2>/dev/null || echo "No historical copy created"

    chmod -R 755 /shared_data/www
    
    echo "Rotating files in /shared_data/www/index"
    find /shared_data/www/index -name "*.html" -mtime +7 -exec rm {} \;
    
    echo "SABER job completed at $(date) with exit code: $exit_code"
    return 0
) | tee /proc/1/fd/1
}

case "$1" in
    run-once)
        run_saber
        result=$?
        echo "Task completed with exit code $result" | tee -a /proc/1/fd/1
        exit $result
        ;;
    serve)
        echo "Service mode. Waiting for scheduler to trigger tasks."
        exec tail -f /dev/null
        ;;
    *)
        if [ -z "$1" ]; then
            echo "No command specified. Starting in service mode"
            exec tail -f /dev/null
        else
            echo "Executing custom command: $@"
            exec "$@"
        fi
        ;;
esac