import { ReactNode } from 'react';

export interface ErrorMessageProps {
  title?: string;
  message: string | ReactNode;
  variant?: 'error' | 'warning' | 'info';
  onRetry?: () => void;
  fullWidth?: boolean;
}

export default function ErrorMessage({
  title,
  message,
  variant = 'error',
  onRetry,
  fullWidth = false,
}: ErrorMessageProps) {
  const variantStyles = {
    error: {
      container: 'bg-red-50 border-red-200',
      icon: 'text-red-500',
      title: 'text-red-800',
      text: 'text-red-700',
    },
    warning: {
      container: 'bg-yellow-50 border-yellow-200',
      icon: 'text-yellow-500',
      title: 'text-yellow-800',
      text: 'text-yellow-700',
    },
    info: {
      container: 'bg-blue-50 border-blue-200',
      icon: 'text-blue-500',
      title: 'text-blue-800',
      text: 'text-blue-700',
    },
  };

  const styles = variantStyles[variant];
  const widthStyle = fullWidth ? 'w-full' : '';

  const icons = {
    error: (
      <path
        strokeLinecap="round"
        strokeLinejoin="round"
        strokeWidth={2}
        d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
      />
    ),
    warning: (
      <path
        strokeLinecap="round"
        strokeLinejoin="round"
        strokeWidth={2}
        d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"
      />
    ),
    info: (
      <path
        strokeLinecap="round"
        strokeLinejoin="round"
        strokeWidth={2}
        d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
      />
    ),
  };

  return (
    <div className={`border rounded-lg p-4 ${styles.container} ${widthStyle}`} role="alert">
      <div className="flex gap-3">
        <svg
          className={`h-6 w-6 flex-shrink-0 ${styles.icon}`}
          fill="none"
          viewBox="0 0 24 24"
          stroke="currentColor"
          aria-hidden="true"
        >
          {icons[variant]}
        </svg>

        <div className="flex-1">
          {title && (
            <h3 className={`text-sm font-semibold mb-1 ${styles.title}`}>
              {title}
            </h3>
          )}

          <div className={`text-sm ${styles.text}`}>
            {message}
          </div>

          {onRetry && (
            <button
              onClick={onRetry}
              className={`mt-3 text-sm font-medium underline hover:no-underline ${styles.text}`}
            >
              Try again
            </button>
          )}
        </div>
      </div>
    </div>
  );
}
