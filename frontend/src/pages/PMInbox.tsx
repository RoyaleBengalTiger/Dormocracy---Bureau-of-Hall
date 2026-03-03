import { useState } from "react";
import { useQuery } from "@tanstack/react-query";
import { motion } from "framer-motion";
import {
    AlertTriangle,
    CheckCircle2,
    Clock,
    Gavel,
    MessageSquare,
    Play,
    Scale,
    Shield,
    ShieldCheck,
    ShieldX,
    Timer,
    XCircle,
} from "lucide-react";
import { useNavigate } from "react-router-dom";

import { violationsApi } from "@/api/violations";
import { CloseEvaluationModal } from "@/components/modals/CloseEvaluationModal";
import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import {
    Select,
    SelectContent,
    SelectItem,
    SelectTrigger,
    SelectValue,
} from "@/components/ui/select";
import { toast } from "@/hooks/use-toast";
import { ViolationStatusEnum, type Violation } from "@/types";

const STATUS_META: Record<string, { label: string; color: string; Icon: typeof AlertTriangle }> = {
    ACTIVE: { label: "Active", color: "bg-red-500/15 text-red-400", Icon: AlertTriangle },
    APPEALED: { label: "Appealed", color: "bg-amber-500/15 text-amber-400", Icon: Gavel },
    IN_EVALUATION: { label: "In Evaluation", color: "bg-blue-500/15 text-blue-400", Icon: MessageSquare },
    CLOSED_UPHELD: { label: "Upheld", color: "bg-red-500/15 text-red-400", Icon: ShieldCheck },
    CLOSED_OVERTURNED: { label: "Overturned", color: "bg-green-500/15 text-green-400", Icon: ShieldX },
    EXPIRED: { label: "Expired", color: "bg-gray-500/15 text-gray-400", Icon: Timer },
};

function StatusBadge({ status }: { status: string }) {
    const m = STATUS_META[status] ?? { label: status, color: "bg-gray-500/15 text-gray-400", Icon: Shield };
    return (
        <span className={`inline-flex items-center gap-1 rounded-full px-2.5 py-0.5 text-xs font-medium ${m.color}`}>
            <m.Icon className="h-3 w-3" />
            {m.label}
        </span>
    );
}

const ALL_FILTER = "__all__";

export default function PMInbox() {
    const navigate = useNavigate();
    const [closeModalId, setCloseModalId] = useState<string | null>(null);
    const [statusFilter, setStatusFilter] = useState(ALL_FILTER);

    const {
        data: appeals = [],
        isLoading,
        refetch,
        error,
    } = useQuery({
        queryKey: ["violations", "appeals"],
        queryFn: violationsApi.getAppeals,
    });

    const filtered = statusFilter === ALL_FILTER
        ? appeals
        : appeals.filter((v) => v.status === statusFilter);

    const handleStartEvaluation = async (id: string) => {
        try {
            await violationsApi.startEvaluation(id);
            toast({ title: "Evaluation started", description: "Case chat created with offender and issuing mayor." });
            refetch();
        } catch (e) {
            const msg = e instanceof Error ? e.message : "Failed to start evaluation";
            toast({ title: "Error", description: msg });
        }
    };

    const formatDate = (iso: string) =>
        new Date(iso).toLocaleDateString(undefined, {
            year: "numeric",
            month: "short",
            day: "numeric",
            hour: "2-digit",
            minute: "2-digit",
        });

    const errorMessage = error instanceof Error ? error.message : "";

    return (
        <div className="min-h-screen p-8">
            <motion.div
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                className="mx-auto max-w-5xl space-y-6"
            >
                {/* ── Header ────────────────────────────────────── */}
                <div className="flex items-center justify-between gap-4">
                    <div>
                        <h1 className="text-4xl font-bold mb-2">PM Inbox</h1>
                        <p className="text-muted-foreground">
                            Appealed &amp; in-evaluation violations from your department.
                        </p>
                    </div>
                    <Button variant="outline" onClick={() => refetch()}>
                        Refresh
                    </Button>
                </div>

                {/* ── Filter ────────────────────────────────────── */}
                <div className="flex flex-col sm:flex-row gap-4">
                    <div className="w-full sm:w-64">
                        <Select value={statusFilter} onValueChange={setStatusFilter}>
                            <SelectTrigger>
                                <SelectValue placeholder="Filter by status" />
                            </SelectTrigger>
                            <SelectContent>
                                <SelectItem value={ALL_FILTER}>All statuses</SelectItem>
                                <SelectItem value={ViolationStatusEnum.APPEALED}>Appealed</SelectItem>
                                <SelectItem value={ViolationStatusEnum.IN_EVALUATION}>In Evaluation</SelectItem>
                                <SelectItem value={ViolationStatusEnum.CLOSED_UPHELD}>Upheld</SelectItem>
                                <SelectItem value={ViolationStatusEnum.CLOSED_OVERTURNED}>Overturned</SelectItem>
                            </SelectContent>
                        </Select>
                    </div>
                </div>

                {/* ── Content ───────────────────────────────────── */}
                {errorMessage ? (
                    <Card className="glass-card">
                        <CardContent className="py-12 text-center text-muted-foreground">
                            {/forbidden|403/i.test(errorMessage)
                                ? "You are not a Prime Minister of any department."
                                : `Error: ${errorMessage}`}
                        </CardContent>
                    </Card>
                ) : isLoading ? (
                    <div className="flex justify-center py-12">
                        <div className="h-8 w-8 animate-spin rounded-full border-4 border-primary border-t-transparent" />
                    </div>
                ) : filtered.length === 0 ? (
                    <Card className="glass-card">
                        <CardContent className="py-12 text-center text-muted-foreground">
                            No cases to review.
                        </CardContent>
                    </Card>
                ) : (
                    <div className="space-y-3">
                        {filtered.map((v: Violation) => {
                            const isClosed = v.status.startsWith("CLOSED_") || v.status === "EXPIRED";

                            return (
                                <Card key={v.id} className="glass-card hover-lift">
                                    <CardContent className="py-4 space-y-3">
                                        {/* Row 1: title + badge + points */}
                                        <div className="flex items-center justify-between gap-4">
                                            <div className="flex items-center gap-2 flex-wrap">
                                                <AlertTriangle className="h-4 w-4 text-destructive shrink-0" />
                                                <span className="font-semibold">{v.title}</span>
                                                <StatusBadge status={v.status} />
                                            </div>
                                            <span className="text-sm font-bold text-destructive whitespace-nowrap">
                                                −{v.points} pts
                                            </span>
                                        </div>

                                        {/* Description */}
                                        {v.description && (
                                            <p className="text-sm text-muted-foreground pl-6">{v.description}</p>
                                        )}

                                        {/* Appeal note */}
                                        {v.appealNote && (
                                            <div className="pl-6 text-sm">
                                                <span className="font-medium">Appeal note: </span>
                                                <span className="text-muted-foreground italic">"{v.appealNote}"</span>
                                            </div>
                                        )}

                                        {/* Verdict info (for closed cases) */}
                                        {v.verdict && (
                                            <div className="pl-6 text-sm">
                                                <span className="font-medium">Verdict: </span>
                                                <span
                                                    className={
                                                        v.verdict === "UPHELD"
                                                            ? "text-red-400"
                                                            : v.verdict === "OVERTURNED"
                                                                ? "text-green-400"
                                                                : "text-amber-400"
                                                    }
                                                >
                                                    {v.verdict.replace(/_/g, " ")}
                                                </span>
                                                {v.verdictNote && (
                                                    <span className="text-muted-foreground"> — {v.verdictNote}</span>
                                                )}
                                            </div>
                                        )}

                                        {/* Metadata row */}
                                        <div className="flex flex-wrap gap-x-5 gap-y-1 text-xs text-muted-foreground pl-6">
                                            <span>
                                                Offender:{" "}
                                                <span className="font-medium text-foreground">{v.offender.username}</span>
                                            </span>
                                            <span>
                                                Issued by:{" "}
                                                <span className="font-medium text-foreground">{v.createdBy.username}</span>
                                            </span>
                                            {v.appealedAt && (
                                                <span className="flex items-center gap-1">
                                                    <Clock className="h-3 w-3" />
                                                    Appealed {formatDate(v.appealedAt)}
                                                </span>
                                            )}
                                            {v.pointsRefunded > 0 && (
                                                <span className="text-green-400">
                                                    +{v.pointsRefunded} pts refunded
                                                </span>
                                            )}
                                        </div>

                                        {/* ── Actions ─────────────────────────── */}
                                        <div className="flex gap-2 pl-6 pt-1">
                                            {/* APPEALED → Start evaluation */}
                                            {v.status === ViolationStatusEnum.APPEALED && (
                                                <Button size="sm" onClick={() => handleStartEvaluation(v.id)}>
                                                    <Play className="mr-1 h-3 w-3" />
                                                    Start Evaluation
                                                </Button>
                                            )}

                                            {/* IN_EVALUATION + chatRoom → Enter case */}
                                            {v.status === ViolationStatusEnum.IN_EVALUATION && v.chatRoom && (
                                                <Button
                                                    size="sm"
                                                    variant="secondary"
                                                    onClick={() => navigate(`/app/pm/violations/${v.id}`)}
                                                >
                                                    <MessageSquare className="mr-1 h-3 w-3" />
                                                    Enter
                                                </Button>
                                            )}

                                            {/* IN_EVALUATION → Close evaluation */}
                                            {v.status === ViolationStatusEnum.IN_EVALUATION && (
                                                <Button
                                                    size="sm"
                                                    variant="destructive"
                                                    onClick={() => setCloseModalId(v.id)}
                                                >
                                                    <Scale className="mr-1 h-3 w-3" />
                                                    Close &amp; Verdict
                                                </Button>
                                            )}

                                            {/* Closed cases with a chat → View readonly */}
                                            {isClosed && v.chatRoom && (
                                                <Button
                                                    size="sm"
                                                    variant="outline"
                                                    onClick={() => navigate(`/app/pm/violations/${v.id}`)}
                                                >
                                                    <MessageSquare className="mr-1 h-3 w-3" />
                                                    View Case
                                                </Button>
                                            )}
                                        </div>
                                    </CardContent>
                                </Card>
                            );
                        })}
                    </div>
                )}

                {/* ── Close Evaluation Modal ─────────────────── */}
                {closeModalId && (
                    <CloseEvaluationModal
                        open={!!closeModalId}
                        onOpenChange={(open) => {
                            if (!open) setCloseModalId(null);
                        }}
                        violationId={closeModalId}
                        onSuccess={() => {
                            setCloseModalId(null);
                            refetch();
                        }}
                    />
                )}
            </motion.div>
        </div>
    );
}
